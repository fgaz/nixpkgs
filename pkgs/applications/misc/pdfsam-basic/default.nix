{ lib, stdenv, makeDesktopItem, fetchurl, jdk21, wrapGAppsHook, glib }:

stdenv.mkDerivation (finalAttrs: {
  pname = "pdfsam-basic";
  version = "5.2.0";

  src = fetchurl {
    url = "https://github.com/torakiki/pdfsam/releases/download/v${finalAttrs.version}/pdfsam_${finalAttrs.version}-1_amd64.deb";
    hash = "sha256-Q1387Su6bmBkXvcrTgWtYZb9z/pKHiOTfUkUNHN8ItY=";
  };

  unpackPhase = ''
    ar vx ${finalAttrs.src}
    tar xvf data.tar.gz
  '';

  nativeBuildInputs = [ wrapGAppsHook ];
  buildInputs = [ glib ];

  preFixup = ''
    gappsWrapperArgs+=(--set JAVA_HOME "${jdk21}" --set PDFSAM_JAVA_PATH "${jdk21}")
  '';

  installPhase = ''
    cp -R opt/pdfsam-basic/ $out/
    mkdir -p "$out"/share/icons
    cp --recursive ${finalAttrs.desktopItem}/share/applications $out/share
    cp $out/icon.svg "$out"/share/icons/pdfsam-basic.svg
  '';

  desktopItem = makeDesktopItem {
    name = finalAttrs.pname;
    exec = finalAttrs.pname;
    icon = finalAttrs.pname;
    comment = finalAttrs.meta.description;
    desktopName = "PDFsam Basic";
    genericName = "PDF Split and Merge";
    mimeTypes = [ "application/pdf" ];
    categories = [ "Office" ];
  };

  meta = with lib; {
    homepage = "https://github.com/torakiki/pdfsam";
    description = "Multi-platform software designed to extract pages, split, merge, mix and rotate PDF files";
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ _1000101 ];
  };
})
