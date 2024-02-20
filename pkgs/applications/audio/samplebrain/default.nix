{ lib
, stdenv
, fetchFromGitLab
, fftw
, liblo
, libsndfile
, makeDesktopItem
, portaudio
, qmake
, qtbase
, wrapQtAppsHook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "samplebrain";
  version = "0.18.5";

  src = fetchFromGitLab {
    owner = "then-try-this";
    repo = "samplebrain";
    rev = "v${finalAttrs.version}_release";
    hash = "sha256-/pMHmwly5Dar7w/ZawvR3cWQHw385GQv/Wsl1E2w5p4=";
  };

  nativeBuildInputs = [
    qmake
    wrapQtAppsHook
  ];

  buildInputs = [
    fftw
    liblo
    libsndfile
    portaudio
    qtbase
  ];

  desktopItem = makeDesktopItem {
    type = "Application";
    desktopName = finalAttrs.pname;
    name = finalAttrs.pname;
    comment = "A sample masher designed by Aphex Twin";
    exec = finalAttrs.pname;
    icon = finalAttrs.pname;
    categories = [ "Audio" ];
  };

  installPhase = ''
    mkdir -p $out/bin
    cp samplebrain $out/bin
    install -m 444 -D desktop/samplebrain.svg $out/share/icons/hicolor/scalable/apps/samplebrain.svg
  '';

  meta = with lib; {
    description = "A custom sample mashing app";
    homepage = "https://thentrythis.org/projects/samplebrain";
    changelog = "https://gitlab.com/then-try-this/samplebrain/-/releases/v${finalAttrs.version}_release";
    maintainers = with maintainers; [ mitchmindtree ];
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
})
