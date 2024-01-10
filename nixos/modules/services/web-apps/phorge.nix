# TODO open issue about ssh support
# TODO add bin wrappers that have a less generic name and that automatically
#   establish a database connection, either by changing user or by exposing the
#   secrets (see for example how attic does it)
{ lib, config, pkgs, ... }:

let
  cfg = config.services.phorge;
  settingsFormat = pkgs.formats.json {};
  configFile = settingsFormat.generate "phorge-config.json" cfg.settings;
  fpm = config.services.phpfpm.pools.phorge;
  localDB = cfg.settings."mysql.host" == "localhost";
  # Match usernames so peer authentication is used
  user = if localDB then cfg.settings."mysql.user" else "phorge";
  protocol = if cfg.useSsl then "https" else "http";
  phpPackage = pkgs.php.buildEnv {
    extensions = { enabled, all }: enabled ++ [
      # Recommended by phorge setup issue:
      # This extension is strongly recommended. Without it, this software must
      # rely on a very inefficient disk-based cache.
      all.apcu
    ];
  };
in
{
  options.services.phorge = {
    enable = lib.mkEnableOption "phorge web service";

    hostName = lib.mkOption {
      type = lib.types.str;
      example = "phorge.example";
      description = "Hostname to use for the nginx vhost";
    };

    usercontentHostName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      example = "phorge-usercontent.example";
      description = ''
        Hostname to use for the user content nginx vhost.
        For security, it should be a different top-level domain from
        services.phorge.hostName. See TODO
        If you want to use a CDN, use settings.TODO
      '';
      default = null;
    };

    useSsl = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to enable SSL";
      default = true;
    };

    maxUploadSize = lib.mkOption {
      type = lib.types.str;
      default = "32M";
      example = "1G";
      description = "The maximum size for uploads.";
    };

    package = lib.mkPackageOption pkgs "phorge" {
      # TODO plugins/extensions?
      example = lib.literalExpression ''
        roundcube.withPlugins (plugins: [ plugins.some_plugin ])
      '';

      extraDescription = ''
        Can be overridden to create an environment that contains phorge and
        third-party plugins.
      '';
    };

    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Password file for the mysql connection.
        MAYBE remove to secretsFile/credentialsFile
        TODO blahblah such as `"mysql.pass"`
        TODO choose and document formatting (json merged with `jq --slurp '.[0] * .[1]' a.json b.json`?
        Note that setting `"mysql.pass"` is not necessary if `settings."mysql.host"`
        is set to `localhost`, as peer authentication will be used.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {

        freeformType = settingsFormat.type;

        # TODO some important options

        options."repository.default-local-path" = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/phorge/repositories";
          description = ''
            TODO
          '';
        };
        options."storage.local-disk.path" = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = "/var/lib/phorge/files";
          description = ''
            Enables the "Local Disk" storage engine and sets the storage path
            (see https://we.phorge.it/book/phorge/article/configuring_file_storage/).
            The directory will be automatically created.
          '';
        };

        options."security.alternate-file-domain" = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "https://foobarusercontent.example";
          description = ''
            If you want TODO automatically set up a nginx alias, use TODO instead
          '';
        };

        options."mysql.user" = lib.mkOption {
          type = lib.types.str;
          default = "phorge";
          description = ''
            TODO mysql user, but also local user if localDB
          '';
        };
        options."mysql.host" = lib.mkOption {
          type = lib.types.str;
          default = "localhost";
          description = ''
          '';
        };

        options."pygments.enabled" = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            TODO
          '';
        };

        options."environment.append-paths" = lib.mkOption {
          type = lib.types.listOf lib.types.path;
          description = ''
            TODO
          '';
          example = lib.literalExpression ''
            [ (lib.makeBinPath [ pkgs.hello ]) ]
          '';
        };

        # Some important settings that we don't use in the service definition
        # but are nice to have defined.
        options."policy.allow-public" = lib.mkOption {
          type = lib.types.bool;
          description = ''
            TODO
          '';
          default = false;
        };

      };
      default = {};
      description = ''
        Configuration for Foo, see
        <link xlink:href="https://example.com/docs/foo"/>
        for supported values.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optional (localDB && cfg.passwordFile != null) "services.phorge.passwordFile is not needed when using a local database";

    # TODO assert that hostname is defined


    services.phorge.settings = {
      "phabricator.base-uri" = lib.mkDefault "${protocol}://${cfg.hostName}";
      "security.alternate-file-domain" = lib.mkDefault
        (if cfg.usercontentHostName != null
        then "${protocol}://${cfg.usercontentHostName}"
        else null);
      "environment.append-paths" = builtins.map (p: lib.makeBinPath [p]) (
        [
          pkgs.diffutils
          pkgs.which
          pkgs.procps
          pkgs.git
          pkgs.subversion
          pkgs.mercurial
        ] ++
        lib.optional cfg.settings."pygments.enabled" pkgs.python3Packages.pygments
      );
    };

    environment.etc."phorge/local.json".source = configFile;

    systemd.tmpfiles.rules = [
      "d ${cfg.settings."repository.default-local-path"} 0750 ${user} ${user}"
    ] ++ lib.optional (cfg.settings."storage.local-disk.path" != null)
      "d ${cfg.settings."storage.local-disk.path"} 0750 ${user} ${user}";


    services.nginx = {
      enable = true;
      virtualHosts = {
        ${cfg.hostName} = {
          serverAliases = lib.optional
            (cfg.usercontentHostName != null)
            cfg.usercontentHostName;
          forceSSL = lib.mkDefault cfg.useSsl;
          enableACME = lib.mkDefault cfg.useSsl;
          locations."/" = {
            root = cfg.package + "/phorge/webroot";
            index = "index.php";
            extraConfig = ''
              rewrite ^/(.*)$ /index.php?__path__=/$1 last;
            '';
          };
          locations."/index.php" = {
            root = cfg.package + "/phorge/webroot";
            extraConfig = ''
              fastcgi_pass unix:${fpm.socket};
              fastcgi_index   index.php;
              fastcgi_buffers 8 16k;
              fastcgi_buffer_size 32k;

              include ${config.services.nginx.package}/conf/fastcgi_params;
              include ${pkgs.nginx}/conf/fastcgi.conf;
            '';
          };
        };
      };
    };

    services.mysql = lib.mkIf localDB {
      enable = true;
      ensureUsers = [{
        name = cfg.settings."mysql.user";
        ensurePermissions = {
          # Allow access to all databases with phabricator_ prefix.
          # It's double-escaped because it ends up in a shell command.
          "\\`phabricator\\\\_%\\`.*" = "ALL PRIVILEGES";
          # Allow health monitoring (available at page /config/cluster/databases)
          "*.*" = "REPLICA MONITOR";
        };
      }];
      # Settings recommended by phorge setup issues
      settings.mysqld = {
        sql_mode = [ "STRICT_ALL_TABLES" ];
        max_allowed_packet = lib.mkDefault 33554432;
        local_infile = lib.mkDefault false;
        # The optimal value of innodb_buffer_pool_size depends on available RAM,
        # so we can't set it here. Instead, we leave it to the default value,
        # so that phorge can inform the user about the setting through a setup issue.
      };
    };

    # TODO MAYBE assign uid/gid
    # TODO (make possible to) differentiate from db user, with warning in doc string about peer auth
    users.users.${user} = {
      group = user;
      isSystemUser = true;
    };
    users.groups.${user} = {};

    services.phpfpm.pools.phorge = {
      inherit user phpPackage;
      phpOptions = ''
        log_errors = on
        post_max_size = ${cfg.maxUploadSize}
        upload_max_filesize = ${cfg.maxUploadSize}
        # Recommended by phorge setup issue
        opcache.validate_timestamps = off
      '';
      # TODO check all this, compare with other services
      settings = lib.mapAttrs (name: lib.mkDefault) {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
        "listen.mode" = "0660";
        "pm" = "dynamic";
        "pm.max_children" = 75;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 20;
        "pm.max_requests" = 500;
        "catch_workers_output" = true;

        "php_admin_value[error_log]" = "stderr";
        "php_admin_flag[log_errors]" = true;
      };
      #phpEnv.PHABRICATOR_ENV = toString configFile; # MAYBE use advanced config
    };
    systemd.services.phpfpm-phorge.after = [ "phorge-setup.service" ];

    # Restart on config changes.
    systemd.services.phpfpm-phorge.restartTriggers = [ configFile ];

    systemd.services.phorge-setup = lib.mkMerge [
      (lib.mkIf localDB {
        requires = [ "mysql.service" ];
        after = [ "mysql.service" ];
      })
      {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          ${cfg.package}/phorge/bin/storage upgrade --force
        '';
        serviceConfig = {
          Type = "oneshot";
          StateDirectory = "phorge";
          User = user;
          #Environment = [ "PHABRICATOR_ENV=${configFile}" ]; # MAYBE use advanced config
        };
      }
    ];

    systemd.services.phorge-phd = lib.mkMerge [
      (lib.mkIf localDB {
        requires = [ "mysql.service" ];
        after = [ "mysql.service" ];
      })
      {
        description = "Phorge Daemons";
        documentation = [ "https://we.phorge.it/book/phorge/article/managing_daemons/" ];
        after = [ "phorge-setup.service" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ configFile ];
        path = [ pkgs.procps pkgs.git pkgs.subversion pkgs.mercurial ];
        serviceConfig = {
          Type = "forking";
          User = user;
          ExecStart = "${cfg.package}/phorge/bin/phd start";
          ExecStop = "${cfg.package}/phorge/bin/phd stop";
          # Hardening (TODO more)
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectHome = true;
        };
      }
    ];
  };

  meta.maintainers = [ lib.maintainers.fgaz ];
}
