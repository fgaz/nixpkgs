{ lib, stdenv
, fetchurl
, gcc-unwrapped
, dpkg
, util-linux
, bash
, makeWrapper
, electron
}:

let
  inherit (stdenv.hostPlatform) system;

  throwSystem = throw "Unsupported system: ${stdenv.hostPlatform.system}";

  sha256 = {
    "x86_64-linux" = "139nlr191bsinx6ixpi2glcr03lsnzq7b0438h3245napsnjpx6p";
  }."${system}" or throwSystem;

  arch = {
    "x86_64-linux" = "amd64";
  }."${system}" or throwSystem;

in

stdenv.mkDerivation (finalAttrs: {
  pname = "terra-station";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/terra-money/station-desktop/releases/download/v${finalAttrs.version}/Terra.Station_${finalAttrs.version}_${arch}.deb";
    inherit sha256;
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    ${dpkg}/bin/dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/${finalAttrs.pname}

    cp -a usr/share/* $out/share
    cp -a "opt/Terra Station/"{locales,resources} $out/share/${finalAttrs.pname}

    substituteInPlace $out/share/applications/station-electron.desktop \
      --replace "/opt/Terra Station/station-electron" ${finalAttrs.pname}

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/${finalAttrs.pname} \
      --add-flags $out/share/${finalAttrs.pname}/resources/app.asar \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ gcc-unwrapped.lib ]}"
  '';

  meta = with lib; {
    description = "Terra station is the official wallet of the Terra blockchain.";
    homepage = "https://docs.terra.money/docs/learn/terra-station/README.html";
    license = licenses.isc;
    maintainers = [ maintainers.peterwilli ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "terra-station";
  };
})
