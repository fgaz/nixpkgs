{ lib
, buildPythonPackage
, fetchPypi
, pillow
}:

buildPythonPackage rec {
  pname = "pafx";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    extension = "zip";
    sha256 = "1nv39j2645f5xkvw3a1hbflkgkxi8pw2l7fa48ss6ma52idf4hhg";
  };

  propagatedBuildInputs = [
    pillow
  ];

  # paste() missing 2 required positional arguments: 'dst' and 'src'
  doCheck = false;
}
