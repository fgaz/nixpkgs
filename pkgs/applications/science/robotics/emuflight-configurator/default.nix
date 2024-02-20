{lib, stdenv, fetchurl, unzip, makeDesktopItem, copyDesktopItems, nwjs
, wrapGAppsHook, gsettings-desktop-schemas, gtk3 }:

stdenv.mkDerivation (finalAttrs: {
  pname = "emuflight-configurator";
  version = "0.4.1";

  src = fetchurl {
    url = "https://github.com/emuflight/EmuConfigurator/releases/download/${finalAttrs.version}/emuflight-configurator_${finalAttrs.version}_linux64.zip";
    sha256 = "sha256-e4HNg5yr9V5LyT0hYP6gzw0tZm4dLidJg5MQtH3L3JI=";
  };

  nativeBuildInputs = [ wrapGAppsHook unzip copyDesktopItems ];

  buildInputs = [ gsettings-desktop-schemas gtk3 ];

  installPhase = ''
    mkdir -p $out/bin $out/share/${finalAttrs.pname}

    cp -r . $out/share/${finalAttrs.pname}/
    install -m 444 -D icon/emu_icon_128.png $out/share/icons/hicolor/128x128/apps/${finalAttrs.pname}.png

    makeWrapper ${nwjs}/bin/nw $out/bin/${finalAttrs.pname} --add-flags $out/share/${finalAttrs.pname}
  '';

  desktopItems = [
    (makeDesktopItem {
      name = finalAttrs.pname;
      exec = finalAttrs.pname;
      icon = finalAttrs.pname;
      comment = "Emuflight configuration tool";
      desktopName = "Emuflight Configurator";
      genericName = "Flight controller configuration tool";
    })
  ];

  meta = with lib; {
    description = "The Emuflight flight control system configuration tool";
    longDescription = ''
      A crossplatform configuration tool for the Emuflight flight control system.
      Various types of aircraft are supported by the tool and by Emuflight, e.g.
      quadcopters, hexacopters, octocopters and fixed-wing aircraft.
      The application allows you to configure the Emuflight software running on any supported Emuflight target.
    '';
    homepage    = "https://github.com/emuflight/EmuConfigurator";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license     = licenses.gpl3Only;
    maintainers = with maintainers; [ beezow ];
    platforms   = platforms.linux;
  };
})
