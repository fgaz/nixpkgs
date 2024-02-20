{ lib, stdenv, fetchgit, autoreconfHook, pkg-config, libxml2 }:

stdenv.mkDerivation (finalAttrs: {
  pname = "evtest";
  version = "1.35";

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ libxml2 ];

  src = fetchgit {
    url = "git://anongit.freedesktop.org/${finalAttrs.pname}";
    rev = "refs/tags/${finalAttrs.pname}-${finalAttrs.version}";
    sha256 = "sha256-xF2dwjTmTOyZ/kmASYWqKfnvqCjw0OmdNKrNMrjNl5g=";
  };

  meta = with lib; {
    description = "Simple tool for input event debugging";
    license = lib.licenses.gpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.bjornfor ];
  };
})
