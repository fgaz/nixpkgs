{ lib, stdenv, fetchurl, pythonPackages }:

stdenv.mkDerivation (finalAttrs: {
  version = "0.7.10";
  pname = "mwic";

  src = fetchurl {
    url = "https://github.com/jwilk/mwic/releases/download/${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-dmIHPehkxpSb78ymVpcPCu4L41coskrHQOg067dprOo=";
  };

  makeFlags=["PREFIX=\${out}"];

  nativeBuildInputs = [
    pythonPackages.wrapPython
  ];

  propagatedBuildInputs = with pythonPackages; [ pyenchant regex ];

  postFixup = ''
    wrapPythonPrograms
  '';

  meta = with lib; {
    homepage = "http://jwilk.net/software/mwic";
    description = "spell-checker that groups possible misspellings and shows them in their contexts";
    license = licenses.mit;
    maintainers = with maintainers; [ matthiasbeyer ];
  };
})

