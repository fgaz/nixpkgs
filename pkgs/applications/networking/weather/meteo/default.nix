{ lib
, stdenv
, fetchFromGitLab
, nix-update-script
, appstream
, desktop-file-utils
, meson
, ninja
, pkg-config
, python3
, vala
, wrapGAppsHook
, glib
, gtk3
, json-glib
, libappindicator
, libsoup
, webkitgtk
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "meteo";
  version = "0.9.9.2";

  src = fetchFromGitLab {
    owner = "bitseater";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    sha256 = "sha256-9+FNpLjiX0zdsUnbBnNSLt/Ma/cqtclP25tl+faPlpU=";
  };

  nativeBuildInputs = [
    appstream
    desktop-file-utils
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    glib
    gtk3
    json-glib
    libappindicator
    libsoup
    webkitgtk
  ];

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Know the forecast of the next hours & days";
    homepage = "https://gitlab.com/bitseater/meteo";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ bobby285271 ];
    platforms = platforms.linux;
    mainProgram = "com.gitlab.bitseater.meteo";
  };
})
