{ stdenv
, lib
, fetchFromGitLab
, kio
, cmake
, extra-cmake-modules
, libvlc
, libv4l
, libX11
, kidletime
, kdelibs4support
, libXScrnSaver
, wrapQtAppsHook
, qtx11extras
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kaffeine";
  version = "2.0.18";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    repo = finalAttrs.pname;
    owner = "Multimedia";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FOaS9gkzkHglbsNBNMwjzbHCNQg3Mbf+9so/Vfbaquc=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    libvlc
    libv4l
    libX11
    kidletime
    qtx11extras
    kdelibs4support
    libXScrnSaver
  ];

  meta = with lib; {
    description = "KDE media player";
    homepage = "https://apps.kde.org/kaffeine/";
    license = licenses.gpl2;
    maintainers = [ maintainers.pasqui23 ];
    platforms = platforms.all;
    mainProgram = "kaffeine";
  };
})
