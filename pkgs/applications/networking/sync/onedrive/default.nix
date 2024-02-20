{ stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, ldc
, installShellFiles
, pkg-config
, curl
, sqlite
, libnotify
, withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd
, systemd
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "onedrive";
  version = "2.4.25";

  src = fetchFromGitHub {
    owner = "abraunegg";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-M6EOJiykmAKWIuAXdm9ebTSX1eVoO+1axgzxlAmuI8U=";
  };

  nativeBuildInputs = [ autoreconfHook ldc installShellFiles pkg-config ];

  buildInputs = [
    curl
    sqlite
    libnotify
  ] ++ lib.optional withSystemd systemd;

  configureFlags = [
    "--enable-notifications"
  ] ++ lib.optionals withSystemd [
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-systemduserunitdir=${placeholder "out"}/lib/systemd/user"
  ];

  # we could also pass --enable-completions to configure but we would then have to
  # figure out the paths manually and pass those along.
  postInstall = ''
    installShellCompletion --bash --name ${finalAttrs.pname}  contrib/completions/complete.bash
    installShellCompletion --zsh  --name _${finalAttrs.pname} contrib/completions/complete.zsh
    installShellCompletion --fish --name ${finalAttrs.pname}  contrib/completions/complete.fish
  '';

  meta = with lib; {
    description = "A complete tool to interact with OneDrive on Linux";
    homepage = "https://github.com/abraunegg/onedrive";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ srgom peterhoeg bertof ];
    platforms = platforms.linux;
  };
})
