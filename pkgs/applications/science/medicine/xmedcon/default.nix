{ stdenv
, lib
, fetchurl
, gtk3
, glib
, pkg-config
, libpng
, zlib
, wrapGAppsHook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xmedcon";
  version = "0.23.0";

  src = fetchurl {
    url = "mirror://sourceforge/${finalAttrs.pname}/${finalAttrs.pname}-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-g1CRJDokLDzB+1YIuVQNByBLx01CI47EwGeluqVDujk=";
  };

  buildInputs = [
    gtk3
    glib
    libpng
    zlib
  ];

  nativeBuildInputs = [ pkg-config wrapGAppsHook ];

  meta = with lib; {
    description = "An open source toolkit for medical image confinalAttrs.version ";
    homepage = "https://xmedcon.sourceforge.net/";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ arianvp flokli ];
    platforms = platforms.darwin ++ platforms.linux;
  };
})
