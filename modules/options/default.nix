{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with types; let
  cfg = config.services.declarative-jellyfin;
  apikeyOpts = _: {
    options = {
      key = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          The API key (GUID).
          WARNING: This is stored in plain text
        '';
        example = "78878bf9fc654ff78ae332c63de5aeb6";
      };
      keyPath = mkOption {
        type = nullOr path;
        default = null;
        description = ''
          Path to a file containing API key.
          The key is a random GUID. To generate one, run:
          ```uuidgen -r | sed 's/-//g'```
        '';
      };
    };
  };
in {
  imports = [
    ./system.nix
    ./encoding.nix
    ./network.nix
    ./branding.nix
    ./users.nix
    ./libraries.nix
    ./plugins.nix
  ];
  options.services.declarative-jellyfin = {
    enable = mkEnableOption "Jellyfin Service";

    apikeys = mkOption {
      description = "API keys configuration";
      default = {};
      type = attrsOf (submodule apikeyOpts);
      example = {
        Jellyseerr = {
          # You can use `key`, but use with caution! It is stored in plain text
          keyPath = config.sops.secrets.my-jellyfin-jellyseerr-key.path;
        };
      };
    };

    # Jellyfin wrapped options
    user = mkOption {
      type = str;
      default = "jellyfin";
      description = "User account under which jellyfin runs";
    };

    group = mkOption {
      type = str;
      default = "jellyfin";
      description = "Group under which jellyfin runs";
    };
    dataDir = mkOption {
      type = path;
      default = "/var/lib/jellyfin";
      description = ''
        Base data directory,
        passed with `--datadir` see [#data-directory](https://jellyfin.org/docs/general/administration/configuration/#data-directory)
      '';
    };

    configDir = mkOption {
      type = path;
      default = "${cfg.dataDir}/config";
      defaultText = "\${cfg.dataDir}/config";
      description = ''
        Directory containing the server configuration files,
        passed with `--configdir` see [configuration-directory](https://jellyfin.org/docs/general/administration/configuration/#configuration-directory)
      '';
    };

    cacheDir = mkOption {
      type = path;
      default = "/var/cache/jellyfin";
      description = ''
        Directory containing the jellyfin server cache,
        passed with `--cachedir` see [#cache-directory](https://jellyfin.org/docs/general/administration/configuration/#cache-directory)
      '';
    };

    logDir = mkOption {
      type = path;
      default = "${cfg.dataDir}/log";
      defaultText = "\${cfg.dataDir}/log";
      description = ''
        Directory where the Jellyfin logs will be stored,
        passed with `--logdir` see [#log-directory](https://jellyfin.org/docs/general/administration/configuration/#log-directory)
      '';
    };

    openFirewall = mkOption {
      type = bool;
      default = false;
      description = ''
        Open the configured ports in the firewall for the media server.
      '';
    };

    package = mkOption {
      type = package;
      default = pkgs.jellyfin.overrideAttrs (
        let
          lock = builtins.fromJSON (builtins.readFile ../../jellyfin-lock.json);
        in {
          inherit (lock) version;
          src = pkgs.fetchFromGitHub lock.src;
        }
      );
      defaultText = "pkgs.jellyfin";
      description = "Which package to use. Overrides `services.jellyfin.package`";
    };

    # Backup options
    backups = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether or not to make a backup before we update jellyfin configs and DB.
        Disable at your own risk!
      '';
    };

    backupDir = mkOption {
      type = str;
      default = "/var/lib/jellyfin/backups";
      description = ''
        The directory to store backups
      '';
    };

    backupCount = mkOption {
      type = int;
      default = 5;
      description = ''
        The amount of backups that gets rotated, ie. how many backups to
        store before starting to delete old ones
      '';
    };

    # TODO: server id
    serverId = mkOption {
      type = nullOr str;
      default = null;
      example = "f4655afd22f348e19089c6b474b24a73";
      description = ''
        The ID for this server. Generate one with the following command:
        `uuidgen -r | sed 's/-//g'`
      '';
    };
  };

  config.assertions = [
    {
      assertion = all (apikey: (apikey.key != null) || (apikey.keyPath != null)) (attrValues cfg.apikeys);
      message = "API key must be spcecified";
    }
    {
      assertion = all (
        userOpts: !(userOpts.preferences.enabledLibraries != [] && userOpts.permissions.enableAllFolders)
      ) (attrValues cfg.users);
      message = ''
        When specifying custom library access with `Preferences.EnabledLibraries`, you have
        to set `Permission.EnableAllFolders = false` for the user.
      '';
    }
    {
      assertion = all (
        userOpts:
          (lib.count isNull [
            userOpts.password
            userOpts.hashedPassword
            userOpts.hashedPasswordFile
          ])
          == 2
      ) (attrValues cfg.users);
      message = ''
        For a user, exactly one of `password`, `hashedPassword` and `hashedPasswordFile` should be defined.
      '';
    }
  ];
}
