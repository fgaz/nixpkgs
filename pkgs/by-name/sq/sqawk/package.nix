{
  lib,
  tcl,
  tclPackages,
  fetchFromGitHub,
}:

tcl.mkTclDerivation rec {
  pname = "sqawk";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "dbohdan";
    repo = "sqawk";
    rev = "v${version}";
    hash = "sha256-ES7P9m/meudN3RKd3DgFMuaTChyMwus7cKEYxasi/3w=";
  };

  makeFlags = [ "prefix=$(out)" ];

  buildInputs = [
    tclPackages.tcllib
  ];

  meta = {
    description = "Like awk but with SQL and table joins";
    homepage = "https://github.com/dbohdan/sqawk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    mainProgram = "sqawk";
    platforms = lib.platforms.all;
  };
}
