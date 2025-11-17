{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.declarative-jellyfin;
  genhash = import ./pbkdf2-sha512.nix {inherit pkgs;};
  djLib = import ../lib {nixpkgs = pkgs;};
  toXml' = djLib.toXMLGeneric;
  inherit (djLib) toPascalCase;
  isStrList = x: all isString x;
  prepass = x:
    if (isAttrs x)
    then
      if !(hasAttr "tag" x)
      then
        attrsets.mapAttrsToList (tag: value: {
          inherit tag;
          content = prepass value;
        })
        x
      else if (hasAttr "content" x)
      then {
        inherit (x) tag;
        content = prepass x.content;
      }
      else x
    else if (isList x)
    then
      if (isStrList x)
      then
        (map (content: {
            tag = "string";
            inherit content;
          })
          x)
      else map prepass x
    else x;

  toXml = tag: x: (toXml' {
    inherit tag;
    attrib = {
      "xmlns:xsi" = "http://www.w3.org/2001/XMLSchema-instance";
      "xmlns:xsd" = "http://www.w3.org/2001/XMLSchema";
    };
    content = prepass x;
  });
  log = "/var/log/jellyfin.txt";
  print = msg: ''echo "${msg}" | tee --append ${log}'';
  jellyfinConfigFiles = {
    "network.xml" = {
      name = "NetworkConfiguration";
      content = toPascalCase.fromAttrsRecursive cfg.network;
    };
    "encoding.xml" = {
      name = "EncodingOptions";
      content = toPascalCase.fromAttrsRecursive cfg.encoding;
    };
    "system.xml" = {
      name = "ServerConfiguration";
      content = toPascalCase.fromAttrsRecursive cfg.system;
    };
    "branding.xml" = {
      name = "BrandingOptions";
      content = toPascalCase.fromAttrsRecursive cfg.branding;
    };
  };

  # See: https://github.com/jellyfin/jellyfin/blob/master/src/Jellyfin.Database/Jellyfin.Database.Implementations/Enums/PermissionKind.cs
  permissionKindToDBInteger = {
    isAdministrator = 0;
    isHidden = 1;
    isDisabled = 2;
    enableSharedDeviceControl = 3;
    enableRemoteAccess = 4;
    enableLiveTvManagement = 5;
    enableLiveTvAccess = 6;
    enableMediaPlayback = 7;
    enableAudioPlaybackTranscoding = 8;
    enableVideoPlaybackTranscoding = 9;
    enableContentDeletion = 10;
    enableContentDownloading = 11;
    enableSyncTranscoding = 12;
    enableMediaConversion = 13;
    enableAllDevices = 14;
    enableAllChannels = 15;
    enableAllFolders = 16;
    enablePublicSharing = 17;
    enableRemoteControlOfOtherUsers = 18;
    enablePlaybackRemuxing = 19;
    forceRemoteSourceTranscoding = 20;
    enableCollectionManagement = 21;
    enableSubtitleManagement = 22;
    enableLyricManagement = 23;
  };
  # See: https://github.com/jellyfin/jellyfin/blob/master/src/Jellyfin.Database/Jellyfin.Database.Implementations/Enums/PreferenceKind.cs
  preferenceKindToDBInteger = {
    enabledFolders = 5;
  };
  subtitleModes = {
    default = 0;
    always = 1;
    onlyForce = 2;
    none = 3;
    smart = 4;
  };
  dbname = "jellyfin.db";
  nonDBOptions = [
    "hashedPasswordFile"
    "hashedPassword"
    "mutable"
    "permissions"
    "preferences"
    "_module"
    "maxParentalAgeRating"
  ];
  options = map (camelcase: toPascalCase.fromString camelcase) (
    lib.attrsets.mapAttrsToList (key: _value: "${key}") (
      (builtins.removeAttrs (
          (import ./options/users.nix {inherit lib;})
          .options
          .services
          .declarative-jellyfin
          .users
          .type
          .getSubOptions
          []
        )
        nonDBOptions)
      // {
        username = null;
      }
    )
  );

  sqliteFormat = key: value:
    if (isBool value) # bool -> 1 or 0
    then
      if value
      then "1"
      else "0"
    else if (value == null) # null -> NULL
    then "NULL"
    else if (key == "subtitleMode") # subtitleMode -> 0 | 1 | 2 | 3 | 4
    then subtitleModes.${value}
    else if (isString value)
    then "'${value}'"
    else value;
  sqliteFormatAttrs = attrset: builtins.mapAttrs (name: value: sqliteFormat name value) attrset;

  # This function replicates the LibraryManager.GetNewItemId() from the jellyfin source code.
  # It's used to generate the DB id used for referenceing specific folders/libraries (CollectionFolder)
  # The id of a CollectionFolder (library) is: The Folder class' fullname concattenated
  # with the path of to the library relative from the "virtual" jellyfin root with \ for path seperator
  # This generates a key like MediaBrowser.Controller.Entities.CollectionFolderroot\default\<library name>.
  # This gets converted to UTF-16LE and the md5 hash of that gets used as a GUID.
  # Don't ask me why they do it like this 💀
  genfolderuuid =
    pkgs.writeShellScriptBin "genfolderuuid"
    # bash
    ''
      key="root\\default\\$1"
      type="MediaBrowser.Controller.Entities.CollectionFolder"

      # Concatenate type.FullName + key
      input="''${type}''${key}"

      # Convert to UTF-16LE and hash with MD5
      md5hex=$(echo -n "$input" | ${pkgs.iconv}/bin/iconv -f UTF-8 -t UTF-16LE | md5sum | ${pkgs.gawk}/bin/awk '{print $1}')

      # Format as GUID with .NET byte order (little-endian for first 3 fields)
      a="''${md5hex:6:2}''${md5hex:4:2}''${md5hex:2:2}''${md5hex:0:2}"
      b="''${md5hex:10:2}''${md5hex:8:2}"
      c="''${md5hex:14:2}''${md5hex:12:2}"
      d="''${md5hex:16:4}"
      e="''${md5hex:20:12}"

      guid="''${a}-''${b}-''${c}-''${d:0:4}-''${d:4:8}''${e}"

      # Lowercase to match .NET format
      echo "$(echo $guid | tr '[:upper:]' '[:lower:]')"
    '';

  optionsNoId = lib.lists.remove "Id" (lib.lists.remove "InternalId" options);
  genUser = index: username: userOpts: let
    mutatedUser =
      builtins.removeAttrs (
        userOpts
        // {
          inherit username;
          id =
            if userOpts.id != null
            then userOpts.id
            else "$(${pkgs.libuuid}/bin/uuidgen | ${pkgs.coreutils}/bin/tr '[:lower:]' '[:upper:]')";
          internalId =
            if userOpts.internalId != null
            then userOpts.internalId
            else "$(($maxIndex+${toString (index + 1)}))";
          password =
            if userOpts.hashedPasswordFile != null
            then "$(${pkgs.coreutils}/bin/cat \"${userOpts.hashedPasswordFile}\")"
            else if userOpts.hashedPassword != null
            then "$(echo -n '${userOpts.hashedPassword}')"
            else "$(${genhash}/bin/genhash -k \"${userOpts.password}\" -i 210000 -l 128 -u)";
          maxParentalRatingSubScore =
            if !(builtins.isNull userOpts.maxParentalAgeRating)
            then
              builtins.abort
              "`maxParentalAgeRating` has been renamed to `maxParentalRatingSubScore`. The user ${userOpts.username} still has `maxParentalAgeRating` defined."
            else userOpts.maxParentalRatingSubScore;
        }
      )
      nonDBOptions;
    userWithNoId = removeAttrs mutatedUser [
      "id"
      "internalId"
    ];
  in
    # bash
    ''
      userExists=$(${sq} "SELECT 1 FROM Users WHERE Username = '${mutatedUser.username}'")
      userId="${mutatedUser.id}"
      if [ -n "$userExists" ]; then
        # If the user already exists, we must update the user id to match the id in the DB,
        # rather than the randomly generated one
        userId=$(${sq} "SELECT Id FROM Users WHERE Username = '${mutatedUser.username}'")
      fi
      ${print "User id for ${mutatedUser.username} is: $userId"}

      # If the user is mutable, only insert the user if it doesn't already exist, otherwise just overwrite
      if [ ${
        if userOpts.mutable
        then "-z $userExists" # user doesn't exist
        else "-n \"true\""
      } ]; then
        sql="INSERT INTO Users (${concatStringsSep "," optionsNoId}, InternalId, Id) VALUES(${concatStringsSep "," (map toString (attrValues (sqliteFormatAttrs userWithNoId)))},$(($maxIndex+${toString (index + 1)})), $(echo "'$userId'"))"
        # User already exists - don't insert a new Id, just re-use the one already present,
        # so any foreign key relations don't fail because of overwriting with newly generated ID.
        if [ -n "$userExists" ]; then
          ${print "Excluding insertion of Id/InternalId, since user already exists in DB"}
           sql="UPDATE Users SET ${
        concatStringsSep "," (
          map (
            {
              fst,
              snd,
            }:
            # bash
            ''${fst} = ${toString (sqliteFormat fst snd)}''
          ) (lib.lists.zipLists optionsNoId (attrValues userWithNoId))
        )
      } WHERE Username = '${mutatedUser.username}'"
        fi
        echo "''${sql};" >> "$dbcmds"

        # Handle admin user preferences
        ${
        lib.optionalString (userOpts.preferences.enabledLibraries != [])
        # bash
        ''
          echo "REPLACE INTO Preferences(Kind, RowVersion, UserId, Value) VALUES(${toString preferenceKindToDBInteger.enabledFolders}, 0, $(echo "'$userId'"),
          '${
            concatStringsSep "," (
              map (
                enabledLib: "$(${genfolderuuid}/bin/genfolderuuid \"${enabledLib}\")"
              )
              userOpts.preferences.enabledLibraries
            )
          }');" >> "$dbcmds"
        ''
      }

        # Handle user permissions
        ${concatStringsSep "\n" (
        lib.attrsets.mapAttrsToList (
          permission: enabled:
          # bash
          ''
            sql="REPLACE INTO Permissions (Kind, Value, UserId, Permission_Permissions_Guid, RowVersion) VALUES(${
              toString permissionKindToDBInteger.${permission}
            }, ${
              if enabled
              then "1"
              else "0"
            }, $(echo "'$userId'"), NULL, 0);"
            echo "$sql" >> "$dbcmds"
          ''
        )
        userOpts.permissions
      )}
      fi
    '';

  prepassedLibraries =
    builtins.mapAttrs (
      name: value:
        toPascalCase.fromAttrsRecursive (
          value
          // {
            typeOptions =
              mapAttrsToList (name: value: {
                typeOptions =
                  value
                  // (with value; {
                    type = name;
                    metadataFetcherOrder = metadataFetchers;
                    imageFetcherOrder = imageFetchers;
                  });
              })
              cfg.libraries."${name}".typeOptions;
            pathInfos = builtins.map (x: {MediaPathInfo.Path = x;}) value.pathInfos;
          }
        )
    )
    cfg.libraries;

  sq = "${pkgs.sqlite}/bin/sqlite3 \"${config.services.jellyfin.dataDir}/data/${dbname}\" --";
  dbcmdfile = "dbcommands.sql";
  jellyfinDoneTag = "/var/log/jellyfin-init-done";
  configDerivations =
    mapAttrs (
      file: cfg: pkgs.writeText file (toXml cfg.name cfg.content)
    )
    jellyfinConfigFiles;
  jellyfin-exec = "${getExe config.services.jellyfin.package} --datadir '${config.services.jellyfin.dataDir}' --configdir '${config.services.jellyfin.configDir}' --cachedir '${config.services.jellyfin.cacheDir}' --logdir '${config.services.jellyfin.logDir}'";
  jellyfin-init =
    pkgs.writeShellScriptBin "jellyfin-init"
    # bash
    ''
        set -euo pipefail
        rm -rf "${jellyfinDoneTag}"
        trap cleanup EXIT SIGINT SIGTERM SIGHUP SIGQUIT
        trap handle_error ERR

        # u=rwx
        # g=r-x
        # o=---
        umask 027

        # Setup directories
        install -d -m 750 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} "${config.services.jellyfin.configDir}"
        install -d -m 750 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} "${config.services.jellyfin.logDir}"
        install -d -m 750 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} "${config.services.jellyfin.cacheDir}"
        install -d -m 750 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} "${config.services.jellyfin.dataDir}/metadata"
        install -d -m 750 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} "${config.services.jellyfin.dataDir}/playlists"
        install -d -m 750 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} "${config.services.jellyfin.dataDir}/wwwroot"
        install -d -m 750 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} "${config.services.jellyfin.dataDir}/plugins/configurations"

        install -Dm 774 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} /dev/null "${log}"

        ${print "Log init"}

        function handle_error() {
          ${print "An ERROR occured during jellyfin-init!"}
          ${print "Log file:\n$(cat \"${log}\")"}
        }

        function cleanup() {
          ${print "REMOVING DONE TAG"}
          rm -rf "${jellyfinDoneTag}"
        }

        dbcmds="$(mktemp -d)/${dbcmdfile}"
        install -Dm 774 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} /dev/null "$dbcmds"
        trap "rm -rf \"$dbcmds\"" exit
        echo "BEGIN TRANSACTION;" > "$dbcmds"


          # Install each config
          ${concatStringsSep "\n" (
        mapAttrsToList (
          file: path: ''install -Dm 640 "${path}" "${config.services.jellyfin.configDir}/${file}"''
        )
        configDerivations
      )}

          ${
        lib.optionalString cfg.system.isStartupWizardCompleted
        # bash
        ''
          # migrations.xml is no longer generated. We now check if migrations have run
          # by checking if the migrations table exists in the db
          # https://github.com/Sveske-Juice/declarative-jellyfin/issues/17
          if [ -z "$(${sq} "SELECT name FROM sqlite_master WHERE type='table' AND name='__EFMigrationsHistory'")" ]; then
            echo "First time run and no migrations table in DB. We run jellyfin once to generate it..."
            echo "Starting jellyfin with IsStartupWizardCompleted = false"
            ${pkgs.xmlstarlet}/bin/xmlstarlet ed -L -u "//IsStartupWizardCompleted" -v "false" "${config.services.jellyfin.configDir}/system.xml"
            ${jellyfin-exec} & disown
            echo "Waiting for jellyfin to run migrations"
            until [ -n "$(${sq} "SELECT name FROM sqlite_master WHERE type='table' AND name='__EFMigrationsHistory'")" ];
            do
              sleep 1
            done
            sleep 15
            echo "Migrations ran! Restarting jellyfin..."
            ${pkgs.procps}/bin/pkill -15 -f ${config.services.jellyfin.package}
            echo "Waiting for jellyfin to shut down properly"
            while ${pkgs.ps}/bin/ps axg | ${pkgs.gnugrep}/bin/grep -vw grep | ${pkgs.gnugrep}/bin/grep -w ${config.services.jellyfin.package} > /dev/null; do sleep 1 && printf "."; done
            echo "Jellyfin terminated. Resetting with IsStartupWizardCompleted set to true"
            ${pkgs.xmlstarlet}/bin/xmlstarlet ed -L -u "//IsStartupWizardCompleted" -v "true" "${config.services.jellyfin.configDir}/system.xml"
          fi
        ''
      }

        # Make sure there is a database
        if [ ! -e "${config.services.jellyfin.dataDir}/data/${dbname}" ]; then
          ${print "No DB found. First time run detected. Launching jellyfin once to generate initial config + DB..."}
          ${jellyfin-exec} & disown

          ${print "Waiting for jellyfin finish startup"}
          until [ -f "${config.services.jellyfin.dataDir}/data/${dbname}" ]
          do
            sleep 1
          done
          sleep 5
          ${print "Initial jellyfin setup done"}
          ${pkgs.procps}/bin/pkill -15 -f ${config.services.jellyfin.package}
          ${print "Waiting for jellyfin to shut down properly"}
          while ${pkgs.ps}/bin/ps axg | ${pkgs.gnugrep}/bin/grep -vw grep | ${pkgs.gnugrep}/bin/grep -w ${config.services.jellyfin.package} > /dev/null; do sleep 1 && printf "."; done
          cat "${config.services.jellyfin.configDir}/migrations.xml"
          ${print "Jellyfin terminated"}
        fi

      # Rotating backups
      ${
        lib.optionalString cfg.backups
        # bash
        ''
          # Make sure ${cfg.backupDir} exists
          install -d -m 775 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} "${cfg.backupDir}"
          backupName="${cfg.backupDir}/backup_$(date +%Y%m%d%H%M%S%N).tar.gz"

          install -Dm 775 -o ${config.services.jellyfin.user} -g ${config.services.jellyfin.group} /dev/null "$backupName"
          ${print "Creating backup: $backupName"}
          ${pkgs.gnutar}/bin/tar -c --exclude "${removePrefix "/" cfg.backupDir}" -C / ${removePrefix "/" config.services.jellyfin.logDir} -C / ${removePrefix "/" config.services.jellyfin.dataDir} -C / ${removePrefix "/" config.services.jellyfin.configDir} -C / ${removePrefix "/" config.services.jellyfin.cacheDir} -f - | ${pkgs.pigz}/bin/pigz > "$backupName"

          # Rotate backups
          num_backups=$(ls -1 "${cfg.backupDir}" | wc -l)
          num_backups_to_remove=$((num_backups - ${toString cfg.backupCount}))

          if [ $num_backups_to_remove -gt 0 ]; then
            old_backups=$(ls -1 "${cfg.backupDir}" | sort | head -n "$num_backups_to_remove")
            for old_backup in $old_backups; do
              rm "${cfg.backupDir}/$old_backup"
              ${print "Purged backup: $old_backup"}
            done
          fi
        ''
      }

      # Server id
      ${
        lib.optionalString (cfg.serverId != null) # bash
        
        ''
          install -Dm 740 /dev/null "${config.services.jellyfin.dataDir}/data/device.txt"
          echo -n "${cfg.serverId}" > "${config.services.jellyfin.dataDir}/data/device.txt"
        ''
      }

        maxIndex=$(${sq} 'SELECT InternalId FROM Users ORDER BY InternalId DESC LIMIT 1')
        if [ -z "$maxIndex" ]; then
          maxIndex="1"
        fi
        ${print "Max index: $maxIndex"}

        # Generate each user
        ${concatStringsSep "\n" (
        map
        (
          {
            fst,
            snd,
          }:
            genUser fst snd cfg.users.${snd}
        )
        (
          lib.lists.zipLists (builtins.genList (x: x) (builtins.length (builtins.attrValues cfg.users))) (
            builtins.attrNames cfg.users
          )
        )
      )}

        # Handle libraries
        ${builtins.concatStringsSep "\n" (
        mapAttrsToList (
          name: value: let
            path = "${config.services.jellyfin.dataDir}/root/default/${name}";
          in
            # bash
            ''
              install -Dm 740 '${pkgs.writeText "options.xml" (toXml "LibraryOptions" value)}' "${path}/options.xml"
              touch "${path}/${value.ContentType}.collection"
              # Create .mblink files foreach path in library
              ${concatStringsSep "\n" (
                map (
                  pathInfo:
                  # bash
                  ''
                    install -Dm 740 /dev/null "${config.services.jellyfin.dataDir}/root/default/${name}/${baseNameOf pathInfo.MediaPathInfo.Path}.mblink"
                    echo -n "${pathInfo.MediaPathInfo.Path}" > "${config.services.jellyfin.dataDir}/root/default/${name}/${baseNameOf pathInfo.MediaPathInfo.Path}.mblink"
                  ''
                )
                value.PathInfos
              )}
            ''
        )
        prepassedLibraries
      )}

        # API Keys
        ${concatStringsSep "\n" (
        mapAttrsToList (
          appName: value:
          # bash
          ''
            echo "REPLACE INTO ApiKeys (DateCreated, DateLastActivity, Name, AccessToken) VALUES(time(), time(), '${appName}', ${
              if value.key != null
              then "'${value.key}'"
              else "'$(cat \"${value.keyPath}\")'"
            });" >> "$dbcmds"
          ''
        )
        cfg.apikeys
      )}

      # Commit SQL commands
      echo "COMMIT TRANSACTION;" >> "$dbcmds"
      ${print "Executing SQL Commands:\n$(cat \"$dbcmds\")"}
      ${pkgs.sqlite}/bin/sqlite3 "${config.services.jellyfin.dataDir}/data/${dbname}" < "$dbcmds"

      touch '${jellyfinDoneTag}'
      ${jellyfin-exec}
    '';
in {
  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      inherit
        (cfg)
        user
        group
        dataDir
        configDir
        cacheDir
        logDir
        package
        ;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.network.publicHttpPort
      cfg.network.publicHttpsPort
    ];
    systemd.services.jellyfin.serviceConfig.ExecStart =
      lib.mkForce "+${jellyfin-init}/bin/jellyfin-init";
  };
}
