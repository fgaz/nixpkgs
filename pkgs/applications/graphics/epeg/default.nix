{ lib, stdenv, fetchFromGitHub, pkg-config, libtool, autoconf, automake
, libjpeg, libexif
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "epeg";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "mattes";
    repo = "epeg";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-lttqarR8gScNIlSrc5uU3FLfvwxxJ2A1S4oESUW7oIw=";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkg-config libtool autoconf automake ];

  propagatedBuildInputs = [ libjpeg libexif ];

  preConfigure = ''
    ./autogen.sh
  '';

  meta = with lib; {
    homepage = "https://github.com/mattes/epeg";
    description = "Insanely fast JPEG/ JPG thumbnail scaling";
    platforms = platforms.linux ++ platforms.darwin;
    license = {
      url = "https://github.com/mattes/epeg#license";
    };
    maintainers = with maintainers; [ nh2 ];
  };
})
