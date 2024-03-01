{ lib
, stdenv
, fetchurl
, openjdk
, libnotify
, makeWrapper
, tor
, p7zip
, bash
, writeScript
}:
let

  briar-tor = writeScript "briar-tor" ''
    #! ${bash}/bin/bash
    exec ${tor}/bin/tor "$@"
  '';

in
stdenv.mkDerivation (finalAttrs: {
  pname = "briar-desktop";
  version = "0.5.0-beta";

  src = fetchurl {
    url = "https://desktop.briarproject.org/jars/linux/${finalAttrs.version}/briar-desktop-linux-${finalAttrs.version}.jar";
    hash = "sha256-J93ODYAiRbQxG2BF7P3H792ymAcJ3f07l7zRSw8kM+E=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    p7zip
  ];

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp ${finalAttrs.src} $out/lib/briar-desktop.jar
    makeWrapper ${openjdk}/bin/java $out/bin/briar-desktop \
      --add-flags "-jar $out/lib/briar-desktop.jar" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
        libnotify
      ]}"
  '';

  fixupPhase = ''
    # Replace the embedded Tor binary (which is in a Tar archive)
    # with one from Nixpkgs.
    cp ${briar-tor} ./tor
    for arch in {aarch64,armhf,x86_64}; do
      7z a tor_linux-$arch.zip tor
      7z a $out/lib/briar-desktop.jar tor_linux-$arch.zip
    done
  '';

  meta = with lib; {
    description = "Decentalized and secure messnger";
    homepage = "https://code.briarproject.org/briar/briar-desktop";
    license = licenses.gpl3;
    maintainers = with maintainers; [ onny ];
    platforms = [ "x86_64-linux" ];
  };
})
