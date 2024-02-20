{ lib, stdenv, fetchFromGitLab }:

stdenv.mkDerivation (finalAttrs: {
  pname = "mafft";
  version = "7.520";

  src = fetchFromGitLab {
    owner = "sysimm";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-H+EcKahJWwidAx+IUT4uCZEty+S8hUeMSB8VbTu5SmQ=";
  };

  preBuild = ''
    cd ./core
    make clean
  '';

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "PREFIX=$(out)" ];

  meta = with lib;
    {
      description = "Multiple alignment program for amino acid or nucleotide sequences";
      homepage = "https://mafft.cbrc.jp/alignment/software/";
      license = licenses.bsd3;
      maintainers = with maintainers; [ natsukium ];
      platforms = platforms.unix;
    };
})
