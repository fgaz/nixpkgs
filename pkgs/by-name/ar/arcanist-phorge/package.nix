{
  lib,
  stdenv,
  bison,
  cacert,
  fetchgit,
  flex,
  php,
  installShellFiles,
  which,
  python3,
  git,
}:

# Make a custom wrapper. If `wrapProgram` is used, arcanist thinks .arc-wrapped is being
# invoked and complains about it being an unknown toolset. We could use `makeWrapper`, but
# then we’d need to still craft a script that does the `php libexec/arcanist/bin/...` dance
# anyway... So just do everything at once.
let
  makeArcWrapper = toolset: ''
    cat << WRAPPER > $out/bin/${toolset}
    #!$shell -e
    export PATH='${php}/bin:${which}/bin'\''${PATH:+':'}\$PATH
    exec ${php}/bin/php $out/libexec/arcanist/bin/${toolset} "\$@"
    WRAPPER
    chmod +x $out/bin/${toolset}
  '';

in
stdenv.mkDerivation (finalAttrs: {
  pname = "arcanist-phorge";
  version = "2025.18";

  src = fetchgit {
    url = "https://we.phorge.it/source/arcanist.git";
    tag = finalAttrs.version;
    hash = "sha256-yiHLMcgszV9jP/8qb9X/t9Vfm3Ad7DpU55cafWPPQHY=";
  };

  patches = [
    ./dont-require-python3-in-path.patch
  ];

  buildInputs = [
    php
    python3
  ];

  nativeBuildInputs = [
    bison
    flex
    installShellFiles
    git
  ];

  postPatch =
    ''
      patchShebangs support/xhpast/bin/xhpast-generate-version.php support/lib/rebuild-map.php
    ''
    + lib.optionalString stdenv.isAarch64 ''
      substituteInPlace support/xhpast/Makefile \
        --replace-fail "-minline-all-stringops" ""
    '';

  buildPhase = ''
    runHook preBuild
    make cleanall -C support/xhpast $makeFlags "''${makeFlagsArray[@]}" -j $NIX_BUILD_CORES
    make xhpast   -C support/xhpast $makeFlags "''${makeFlagsArray[@]}" -j $NIX_BUILD_CORES
    ./support/lib/rebuild-map.php src/
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/libexec
    make install  -C support/xhpast $makeFlags "''${makeFlagsArray[@]}" -j $NIX_BUILD_CORES
    make cleanall -C support/xhpast $makeFlags "''${makeFlagsArray[@]}" -j $NIX_BUILD_CORES
    cp -R . $out/libexec/arcanist
    ln -sf ${cacert}/etc/ssl/certs/ca-bundle.crt $out/libexec/arcanist/resources/ssl/default.pem

    ${makeArcWrapper "arc"}
    ${makeArcWrapper "phage"}

    $out/bin/arc shell-complete --generate --
    installShellCompletion --cmd arc --bash $out/libexec/arcanist/support/shell/rules/bash-rules.sh
    installShellCompletion --cmd phage --bash $out/libexec/arcanist/support/shell/rules/bash-rules.sh
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/arc help diff -- > /dev/null
    $out/bin/phage help alias -- > /dev/null
  '';

  meta = {
    description = "Command line interface to Phorge";
    homepage = "https://phorge.it/";
    license = lib.licenses.asl20;
    mainProgram = "arc";
    maintainers = [
      lib.maintainers.thoughtpolice
      lib.maintainers.fgaz
    ];
    platforms = lib.platforms.unix;
  };
})
