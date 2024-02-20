{ lib, stdenv, fetchurl, pkg-config, libXt }:

stdenv.mkDerivation (finalAttrs: {
  pname = "xscope";
  version = "1.4.1";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${finalAttrs.pname}-${finalAttrs.version}.tar.bz2";
    sha256 = "08zl3zghvbcqy0r5dn54dim84lp52s0ygrr87jr3a942a6ypz01k";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libXt ];

  meta = with lib; {
    description = "program to monitor X11/Client conversations";
    homepage = "https://cgit.freedesktop.org/xorg/app/xscope/";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
    platforms = with platforms; unix;
  };
})

