{ lib, stdenv, fetchurl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "sic";
  version = "1.3";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/sic-${finalAttrs.version}.tar.gz";
    hash = "sha256-MEePqz68dfLrXQjLtbL+3K9IkRbnWi3XGX4+nHM9ZdI=";
  };

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple IRC client";
    homepage = "https://tools.suckless.org/sic/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
