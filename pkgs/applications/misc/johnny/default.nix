{ lib, stdenv, fetchFromGitHub, qt5, john, makeWrapper, makeDesktopItem
, copyDesktopItems }:

stdenv.mkDerivation (finalAttrs: {
  pname = "johnny";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "openwall";
    repo = "johnny";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fwRvyQbRO63iVt9AHlfl+Cv4NRFQmyVsZUQLxmzGjAY=";
  };

  buildInputs = [ john qt5.qtbase ];
  nativeBuildInputs =
    [ makeWrapper copyDesktopItems qt5.wrapQtAppsHook qt5.qmake ];

  installPhase = ''
    install -D ${finalAttrs.pname} $out/bin/${finalAttrs.pname}
    wrapProgram $out/bin/${finalAttrs.pname} \
      --prefix PATH : ${lib.makeBinPath [ john ]}
    install -D README $out/share/doc/${finalAttrs.pname}/README
    install -D LICENSE $out/share/licenses/${finalAttrs.pname}/LICENSE
    install -D resources/icons/${finalAttrs.pname}_128.png $out/share/pixmaps/${finalAttrs.pname}.png
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Johnny";
      desktopName = "Johnny";
      comment = "A GUI for John the Ripper";
      icon = finalAttrs.pname;
      exec = finalAttrs.pname;
      terminal = false;
      categories = [ "Application" "System" ];
      startupNotify = true;
    })
  ];

  meta = with lib; {
    homepage = "https://openwall.info/wiki/john/johnny";
    description = "Open Source GUI frontend for John the Ripper";
    license = licenses.bsd2;
    maintainers = with maintainers; [ Misaka13514 ];
    platforms = platforms.linux;
  };
})
