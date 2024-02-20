{ lib, stdenv, fetchurl }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gerrit";
  version = "3.9.1";

  src = fetchurl {
    url = "https://gerrit-releases.storage.googleapis.com/gerrit-${finalAttrs.version}.war";
    hash = "sha256-WQjzkykKtrXfkNSWcM9GWy8LPMwxJpSbnWjpmslP0HA=";
  };

  buildCommand = ''
    mkdir -p "$out"/webapps/
    ln -s ${finalAttrs.src} "$out"/webapps/gerrit-${finalAttrs.version}.war
  '';

  passthru = {
    # A list of plugins that are part of the gerrit.war file.
    # Use `java -jar gerrit.war ls | grep plugins/` to generate that list.
    plugins = [
      "codemirror-editor"
      "commit-message-length-validator"
      "delete-project"
      "download-commands"
      "gitiles"
      "hooks"
      "plugin-manager"
      "replication"
      "reviewnotes"
      "singleusergroup"
      "webhooks"
    ];
  };

  meta = with lib; {
    homepage = "https://www.gerritcodereview.com/index.md";
    license = licenses.asl20;
    description = "A web based code review and repository management for the git finalAttrs.version control system";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    maintainers = with maintainers; [ flokli zimbatm ];
    platforms = platforms.unix;
  };
})
