{ lib
, stdenv
, fetchurl
, boost
, libmpdclient
, ncurses
, pkg-config
, readline
, libiconv
, icu
, curl
, outputsSupport ? true # outputs screen
, visualizerSupport ? false, fftw # visualizer screen
, clockSupport ? true # clock screen
, taglibSupport ? true, taglib # tag editor
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ncmpcpp";
  version = "0.9.2";

  src = fetchurl {
    url = "https://rybczak.net/ncmpcpp/stable/${finalAttrs.pname}-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-+qv2FXyMsbJKBZryduFi+p+aO5zTgQxDuRKIYMk4Ohs=";
  };

  enableParallelBuilding = true;

  strictDeps = true;

  configureFlags = [ "BOOST_LIB_SUFFIX=" ]
    ++ lib.optional outputsSupport "--enable-outputs"
    ++ lib.optional visualizerSupport "--enable-visualizer --with-fftw"
    ++ lib.optional clockSupport "--enable-clock"
    ++ lib.optional taglibSupport "--with-taglib";

  nativeBuildInputs = [ pkg-config ]
    ++ lib.optional taglibSupport taglib;

  buildInputs = [ boost libmpdclient ncurses readline libiconv icu curl ]
    ++ lib.optional visualizerSupport fftw
    ++ lib.optional taglibSupport taglib;

  meta = with lib; {
    description = "A featureful ncurses based MPD client inspired by ncmpc";
    homepage    = "https://rybczak.net/ncmpcpp/";
    changelog   = "https://github.com/ncmpcpp/ncmpcpp/blob/${finalAttrs.version}/CHANGELOG.md";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ koral lovek323 ];
    platforms   = platforms.all;
    mainProgram = "ncmpcpp";
  };
})
