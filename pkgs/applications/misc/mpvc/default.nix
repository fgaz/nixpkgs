{ lib, stdenv, socat, fetchFromGitHub, makeWrapper }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mpvc";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "lwilletts";
    repo = "mpvc";
    rev = finalAttrs.version;
    sha256 = "sha256-wPETEG0BtNBEj3ZyP70byLzIP+NMUKbnjQ+kdvrvK3s=";
  };

  makeFlags = [ "PREFIX=$(out)" ];
  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/mpvc --prefix PATH : "${socat}/bin/"
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ socat ];

  meta = with lib; {
    description = "A mpc-like control interface for mpv";
    homepage = "https://github.com/lwilletts/mpvc";
    license = licenses.mit;
    maintainers = [ maintainers.neeasade ];
    platforms = platforms.linux;
  };
})
