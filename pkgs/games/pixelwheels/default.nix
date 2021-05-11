{ lib, stdenv
, makeWrapper
, fetchFromGitHub
, nixosTests
, gradle_6
, perl
, python3
, imagemagick
, jre
, openal
}:

let
  pname = "pixelwheels";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "agateau";
    repo = "pixelwheels";
    rev = version;
    sha256 = "1v640yp6n9h8yms9z53yg26cr08xshii3i1anlr8gnif3xj69z48";
  };

  postPatch = ''
    # disable gradle plugins with native code and their targets
    perl -i.bak1 -pe "s#(^\s*id '.+' version '.+'$)#// \1#" build.gradle
    perl -i.bak2 -pe "s#(.*)#// \1# if /^(buildscript|task portable|task nsis|task proguard|task tgz|task\(afterEclipseImport\)|launch4j|macAppBundle|buildRpm|buildDeb|shadowJar)/ ... /^}/" build.gradle
    # Disable unbuildable android project
    sed -i '/^project(":android") {/,/^}/d' build.gradle
    patchShebangs \
      tools/pad-map-tiles \
      tools/asetools/asesplit \
      core/assets-src/sprites/hud/hud.py
  '';

  # fake build to pre-download deps into fixed-output derivation
  deps = stdenv.mkDerivation {
    pname = "${pname}-deps";
    inherit version src postPatch;
    nativeBuildInputs = [ gradle_6 perl ];
    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      # https://github.com/gradle/gradle/issues/4426
      ${lib.optionalString stdenv.isDarwin "export TERM=dumb"}
      gradle --no-daemon tools:dist desktop:dist
    '';
    # perl code mavenizes pathes (com.squareup.okio/okio/1.13.0/a9283170b7305c8d92d25aff02a6ab7e45d06cbe/okio-1.13.0.jar -> com/squareup/okio/okio/1.13.0/okio-1.13.0.jar)
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "1213kzlgq420qjapmw4qnp6bvyjq86sxmavfksn9wm33ri4wq7pb";
  };

in stdenv.mkDerivation rec {
  inherit pname version src postPatch;

  nativeBuildInputs = [
    gradle_6
    jre
    perl
    (python3.withPackages (pp: [ pp.pillow pp.pypng pp.pafx ]))
    imagemagick
    makeWrapper
  ];

  buildPhase = ''
    export GRADLE_USER_HOME=$(mktemp -d)
    # https://github.com/gradle/gradle/issues/4426
    ${lib.optionalString stdenv.isDarwin "export TERM=dumb"}
    # point to offline repo
    sed -ie "s#repositories {#repositories { maven { url '${deps}' };#g" build.gradle
    gradle --offline --no-daemon tools:dist
    make assets
    make packer
    gradle --offline --no-daemon desktop:dist
  '';

  installPhase = ''
    mkdir -p $out/share/java
    # patch openal
    # cannot use --update because the file already exists
    mkdir repack
    pushd repack
    jar --extract --file ../desktop/build/libs/desktop-1.0.jar
    popd
    cp -L ${openal}/lib/libopenal.so repack/libopenal.so
    ls repack
    jar --create \
      --file $out/share/java/pixelwheels.jar \
      --main-class com.agateau.pixelwheels.desktop.DesktopLauncher \
      -C repack \
      .
    mkdir $out/bin
    makeWrapper ${jre}/bin/java $out/bin/pixelwheels \
      --add-flags "-jar $out/share/java/pixelwheels.jar"
  '';

  meta = with lib; {
    homepage = "https://agateau.com/projects/pixelwheels/";
    downloadPage = "https://agateau.itch.io/pixelwheels";
    description = "A top-down retro racing game";
    license = with licenses; [ gpl3Plus asl20 cc-by-sa-40 ];
    maintainers = with maintainers; [ fgaz ];
    platforms = platforms.all;
  };
}
