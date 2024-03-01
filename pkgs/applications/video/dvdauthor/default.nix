{ lib
, stdenv
, fetchurl
, autoreconfHook
, libdvdread
, libxml2
, freetype
, fribidi
, libpng
, zlib
, pkg-config
, flex
, bison
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dvdauthor";
  version = "0.7.2";

  src = fetchurl {
    url = "mirror://sourceforge/dvdauthor/dvdauthor-${finalAttrs.version}.tar.gz";
    hash = "sha256-MCCpLen3jrNvSLbyLVoAHEcQeCZjSnhaYt/NCA9hLrc=";
  };

  buildInputs = [ libpng freetype libdvdread libxml2 zlib fribidi flex bison ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  meta = with lib; {
    description = "Tools for generating DVD files to be played on standalone DVD players";
    homepage = "https://dvdauthor.sourceforge.net/";
    license = licenses.gpl2;
    platforms = platforms.linux ++ platforms.darwin;
  };
})
