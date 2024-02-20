{ lib, stdenv, fetchurl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "iprange";
  version = "1.0.4";

  src = fetchurl {
    url = "https://github.com/firehol/iprange/releases/download/v${finalAttrs.version}/iprange-${finalAttrs.version}.tar.xz";
    sha256 = "0rymw4ydn09dng34q4g5111706fyppzs2gd5br76frgvfj4x2f71";
  };

  meta = with lib; {
    description = "manage IP ranges";
    homepage = "https://github.com/firehol/iprange";
    license = licenses.gpl2;
    maintainers = with maintainers; [ oxzi ];
  };
})
