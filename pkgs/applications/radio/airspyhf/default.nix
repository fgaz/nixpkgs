{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, libusb1 }:

stdenv.mkDerivation (finalAttrs: {
  pname = "airspyhf";
  version = "1.6.8";

  src = fetchFromGitHub {
    owner = "airspy";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-RKTMEDPeKcerJZtXTn8eAShxDcZUMgeQg/+7pEpMyVg=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ libusb1 ];

  meta = with lib; {
    description = "User mode driver for Airspy HF+";
    homepage = "https://github.com/airspy/airspyhf";
    license = licenses.bsd3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
})
