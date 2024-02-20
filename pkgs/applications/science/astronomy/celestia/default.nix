{ lib, stdenv, fetchFromGitHub, pkg-config, freeglut, gtk2, gtkglext
, libjpeg_turbo, libtheora, libXmu, lua, libGLU, libGL, perl, autoreconfHook
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "celestia";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "CelestiaProject";
    repo = "Celestia";
    rev = finalAttrs.version;
    sha256 = "sha256-MkElGo1ZR0ImW/526QlDE1ePd+VOQxwkX7l+0WyZ6Vs=";
  };

  nativeBuildInputs = [ pkg-config autoreconfHook ];
  buildInputs = [
    freeglut gtk2 gtkglext lua perl
    libjpeg_turbo libtheora libXmu libGLU libGL
  ];

  configureFlags = [
    "--with-gtk"
    "--with-lua=${lua}"
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://celestia.space/";
    description = "Real-time 3D simulation of space";
    changelog = "https://github.com/CelestiaProject/Celestia/releases/tag/${finalAttrs.version}";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ hjones2199 ];
    platforms = platforms.linux;
  };
})
