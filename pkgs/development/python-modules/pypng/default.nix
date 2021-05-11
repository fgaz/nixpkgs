{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "pypng";
  version = "0.0.20";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02qpa22ls41vwsrzw9r9qhj1nhq05p03hb5473pay6y980s86chh";
  };
}
