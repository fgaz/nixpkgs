{
  lib,
  buildPythonPackage,
  setuptools-scm,
  pythonOlder,
  fetchFromGitHub,
  pytestCheckHook,
  pytest-xdist,
  numpy,
  numba,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "galois";
  version = "0.4.6";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "mhostetter";
    repo = "galois";
    tag = "v${version}";
    hash = "sha256-KMCShC3oZCPk87rxCYuwdSNXy0i20IQ1gzL9nFqgn0Q=";
  };

  pythonRelaxDeps = [
    "numpy"
    "numba"
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    numpy
    numba
    typing-extensions
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  pythonImportsCheck = [ "galois" ];

  meta = with lib; {
    description = "Python package that extends NumPy arrays to operate over finite fields";
    homepage = "https://github.com/mhostetter/galois";
    changelog = "https://github.com/mhostetter/galois/releases/tag/${src.tag}";
    downloadPage = "https://github.com/mhostetter/galois/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ chrispattison ];
  };
}
