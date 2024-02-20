{ stdenv
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fasthenry";
  # later finalAttrs.versions are Windows only ports
  # nixpkgs-update: no auto update
  version = "3.0.1";

  # we don't use the original MIT code at
  # https://www.rle.mit.edu/cpg/research_codes.htm
  # since the FastFieldSolvers S.R.L. finalAttrs.version includes
  # a couple of bug fixes
  src = fetchFromGitHub {
    owner = "ediloren";
    repo = "FastHenry2";
    rev = "R${finalAttrs.version}";
    sha256 = "017kcri69zhyhii59kxj1ak0gyfn7jf0qp6p2x3nnljia8njdkcc";
  };

  dontConfigure = true;

  preBuild = ''
    makeFlagsArray=(
      CC="gcc"
      RM="rm"
      SHELL="sh"
      "all"
    )
    '' + (if stdenv.isx86_64 then ''
    makeFlagsArray+=(
      CFLAGS="-fcommon -O -DFOUR -m64"
    );
    '' else ''
      makeFlagsArray+=(
        CFLAGS="-fcommon -O -DFOUR"
    );
  '');

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin/* $out/bin/
    mkdir -p $out/share/doc/${finalAttrs.pname}-${finalAttrs.version}
    cp -r doc/* $out/share/doc/${finalAttrs.pname}-${finalAttrs.version}
    mkdir -p $out/share/${finalAttrs.pname}-${finalAttrs.version}/examples
    cp -r examples/* $out/share/${finalAttrs.pname}-${finalAttrs.version}/examples
  '';

  meta = with lib; {
    description = "Multipole-accelerated inductance analysis program";
    longDescription = ''
       Fasthenry is an inductance extraction program based on a
       multipole-accelerated algorithm.'';
    homepage = "https://www.fastfieldsolvers.com/fasthenry2.htm";
    license = licenses.lgpl2Only;
    maintainers = with maintainers; [ fbeffa ];
    platforms = intersectLists (platforms.linux) (platforms.x86_64 ++ platforms.x86);
  };
})
