{ lib
, stdenvNoCC
, fetchgit
, php
, nixosTests
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "phorge";
  version = "2023.49";

  srcs = [
    (fetchgit {
      url = "https://we.phorge.it/source/phorge.git";
      rev = finalAttrs.version;
      hash = "sha256-xRqrRJ/h4idqLdkFM5OPNXpaeUfDJToAV9rDtvtXMCk=";
    })
    (fetchgit {
      url = "https://we.phorge.it/source/arcanist.git";
      rev = finalAttrs.version;
      hash = "sha256-eclh0B9/90ikAV1LB7U1EPysSufFpzvuIKBX1WDngPs=";
    })
  ];

  sourceRoot = ".";

  dontBuild = true;

  buildInputs = [
    php
  ];

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r arcanist phorge $out
    runHook postInstall
  '';

  # Phorge gets its configuration from a file inside the package directory,
  # which is immutable in nix. We fix this by symlinking that file to /etc.
  # Other alternatives are:
  #   * link the entire directory and move conf to conf.example
  #   * use the php stuff to get the local.json location from the environment
  postFixup = ''
    ln -s /etc/phorge/local.json $out/phorge/conf/local/local.json
  '';

  meta = {
    description = "An open source, opinionated, community-driven platform for collaborating, managing, organizing and reviewing software development projects. Fork of Phabricator";
    homepage = "https://phorge.it/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.fgaz ];
    platforms = lib.platforms.unix;
  };
})
