{ stdenv
, lib
, fetchFromGitLab

, gettext
, meson
, ninja
, pkg-config
, python3
, rustPlatform
, wrapGAppsHook4

, appstream-glib
, desktop-file-utils
, glib
, gtk4
, libadwaita
, Foundation
}:

stdenv.mkDerivation rec {
  pname = "gnome-obfuscate";
  version = "0.0.8";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "Obfuscate";
    rev = version;
    sha256 = "sha256-gGQqJd5hAeOXZJ1+MrbchQJK2qPidcgcz8Hr88nZmo8=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    sha256 = "sha256-uycFGFxBNzUlsJoFPvEtb0HifIn3SuWOgbEX8lyS8eU=";
  };

  nativeBuildInputs = [
    gettext
    glib
    meson
    ninja
    pkg-config
    python3
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    appstream-glib
    desktop-file-utils
    glib
    gtk4
    libadwaita
  ] ++ lib.optionals stdenv.isDarwin [
    Foundation
  ];

  postPatch = ''
    patchShebangs build-aux/meson_post_install.py
  '';

  meta = with lib; {
    description = "Censor private information";
    homepage = "https://gitlab.gnome.org/World/obfuscate";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ fgaz ];
    platforms = platforms.all;
  };
}
