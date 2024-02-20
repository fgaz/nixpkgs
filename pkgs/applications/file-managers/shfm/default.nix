{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shfm";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "dylanaraps";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-ilVrUFfyzOZgjbBTqlHA9hLaTHw1xHFo1Y/tjXygNEs=";
  };

  postPatch = ''
    patchShebangs ./shfm
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -D shfm --target-directory $out/bin/
    install -D README --target-directory $out/share/doc/${finalAttrs.pname}/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/dylanaraps/shfm";
    description = "POSIX-shell based file manager";
    license = licenses.mit;
    maintainers = with maintainers; [ AndersonTorres ];
    platforms = platforms.all;
  };
})
