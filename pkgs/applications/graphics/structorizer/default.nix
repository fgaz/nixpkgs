{ stdenv
, lib
, fetchFromGitHub
, jdk11
, makeDesktopItem
, makeWrapper
, copyDesktopItems
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "structorizer";
  version = "3.32-15";

  desktopItems = [
    (makeDesktopItem {
      type = "Application";
      name = "Structorizer";
      desktopName = "Structorizer";
      genericName = "Diagram creator";
      comment = finalAttrs.meta.description;
      icon = finalAttrs.pname;
      exec = finalAttrs.pname;
      terminal = false;
      mimeTypes = [ "application/nsd" ];
      categories = [
        "Development"
        "Graphics"
        "VectorGraphics"
        "RasterGraphics"
        "ComputerScience"
      ];
      keywords = [ "nsd" "diagrams" ];
    })
  ];

  src = fetchFromGitHub {
    owner = "fesch";
    repo = "Structorizer.Desktop";
    rev = finalAttrs.version;
    hash = "sha256-ZCVvMvbXMQIcZRk1F7QiRtNeuLicHe/aEvwp4FvhwoM=";
  };

  patches = [ ./makeStructorizer.patch ./makeBigJar.patch ];

  strictDeps = true;

  nativeBuildInputs = [ jdk11 makeWrapper copyDesktopItems ];

  buildInputs = [ jdk11 ];

  postPatch = ''
    chmod +x makeStructorizer
    chmod +x makeBigJar

    patchShebangs --build makeStructorizer
    patchShebangs --build makeBigJar
  '';

  buildPhase = ''
    runHook preBuild

    ./makeStructorizer
    ./makeBigJar

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d $out/bin $out/share/mime/packages

    install -D ${finalAttrs.pname}.jar -t $out/share/java/
      makeWrapper ${jdk11}/bin/java $out/bin/${finalAttrs.pname} \
      --add-flags "-jar $out/share/java/${finalAttrs.pname}.jar"

    cat << EOF > $out/share/mime/packages/structorizer.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
      <mime-type type="application/nsd">
             <comment xml:lang="en">Nassi-Shneiderman diagram</comment>
             <comment xml:lang="de">Nassi-Shneiderman-Diagramm</comment>
             <glob pattern="*.nsd"/>
      </mime-type>
    </mime-info>
    EOF

    cd src/lu/fisch/${finalAttrs.pname}/gui
    install -vD icons/000_${finalAttrs.pname}.png $out/share/icons/hicolor/16x16/apps/${finalAttrs.pname}.png
    for icon_width in 24 32 48 64 128 256; do
      install -vD icons_"$icon_width"/000_${finalAttrs.pname}.png $out/share/icons/hicolor/"$icon_width"x"$icon_width"/apps/${finalAttrs.pname}.png
    done

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Create Nassi-Shneiderman diagrams (NSD)";
    homepage = "https://structorizer.fisch.lu";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ annaaurora ];
    mainProgram = "structorizer";
  };
})
