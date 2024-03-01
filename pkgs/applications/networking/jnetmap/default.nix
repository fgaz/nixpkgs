{ lib, stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation (finalAttrs: {
  pname = "jnetmap";
  version = "0.5.5";
  versionSuffix = "-703";

  src = fetchurl {
    url = "mirror://sourceforge/project/jnetmap/jNetMap%20${finalAttrs.version}/jNetMap-${finalAttrs.version}${finalAttrs.versionSuffix}.jar";
    sha256 = "sha256-e4Ssm2Sq/v1YZ7ZudAqgQ7Cz2ffwWbSmLFoKhaZvTPg=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    mkdir -p "$out/lib"

    cp "${finalAttrs.src}" "$out/lib/jnetmap.jar"
    makeWrapper "${jre}/bin/java" "$out/bin/jnetmap" \
        --add-flags "-jar \"$out/lib/jnetmap.jar\""

    runHook postInstall
  '';

  meta = with lib; {
    description = "Graphical network monitoring and documentation tool";
    homepage = "http://www.rakudave.ch/jnetmap/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl3Plus;
    # Upstream supports macOS and Windows too.
    platforms = platforms.linux;
    maintainers = [ maintainers.bjornfor ];
  };
})
