{ lib
, stdenv
, fetchFromGitLab
, alsa-lib
, boost
, dbus-glib
, ganv
, glibmm
, gtkmm2
, libjack2
, pkg-config
, python3
, wafHook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "patchage";
  version = "1.0.6";

  src = fetchFromGitLab {
    owner = "drobilla";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-LzN6RyF/VT4LUVeR0904BnLuNMFZjFTDu9oDIKYG2Yo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    alsa-lib
    boost
    dbus-glib
    ganv
    glibmm
    gtkmm2
    libjack2
    python3
    wafHook
  ];

  meta = {
    description = "Modular patch bay for Jack and ALSA systems";
    homepage = "https://drobilla.net/software/patchage.html";
    license = lib.licenses.lgpl3;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.nico202 ];
  };
})
