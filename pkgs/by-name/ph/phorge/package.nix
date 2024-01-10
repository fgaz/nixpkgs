{
  lib,
  stdenvNoCC,
  fetchgit,
  php,
  nixosTests,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "phorge";
  version = "2025.18";

  srcs = [
    (fetchgit {
      url = "https://we.phorge.it/source/phorge.git";
      tag = finalAttrs.version;
      hash = "sha256-q5QHtbC99bmj8CmttwI0UqZQGy3OJL1/Hn9q5tKo3tI=";
    })
    (fetchgit {
      url = "https://we.phorge.it/source/arcanist.git";
      tag = finalAttrs.version;
      hash = "sha256-yiHLMcgszV9jP/8qb9X/t9Vfm3Ad7DpU55cafWPPQHY=";
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
