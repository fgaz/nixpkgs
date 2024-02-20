{ lib, stdenv, fetchFromGitHub, autoreconfHook }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpx";
  version = "2.6.8";

  nativeBuildInputs = [ autoreconfHook ];

  src = fetchFromGitHub {
    owner = "markwal";
    repo = "GPX";
    rev = finalAttrs.version;
    sha256 = "1izs8s5npkbfrsyk17429hyl1vyrbj9dp6vmdlbb2vh6mfgl54h8";
  };

  meta = {
    description = "Gcode to x3g confinalAttrs.version postprocessor";
    homepage = "https://github.com/markwal/GPX/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.leo60228 ];
  };
})
