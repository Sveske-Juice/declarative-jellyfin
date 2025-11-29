{lib, ...}:
with lib; let
  preferenceOpts = _: {
    options = {
      # NOTE: renamed from internal EnabledFolders, since
      # it makes more sense to call it library not folder
      enabledLibraries = mkOption {
        type = types.listOf types.str;
        default = []; # empty means all are enabled
        description = ''
          A list of libraries this user as access to.
          If it is empty, it means that the user has access to all libraries.
          The libraries are specified by the library name specified in
          `services.declarative-jellyfin.libraries.<name>`
        '';
        example = [
          "Movies"
          "Family Photos"
        ];
      };
    };
  };
  # See: https://github.com/jellyfin/jellyfin/blob/master/src/Jellyfin.Database/Jellyfin.Database.Implementations/Enums/PermissionKind.cs
  # Defaults: https://github.com/jellyfin/jellyfin/blob/master/Jellyfin.Data/UserEntityExtensions.cs#L170
  permissionOpts = _: {
    options = {
      isAdministrator = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the user is an administrator";
      };
      isHidden = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user is hidden";
      };
      isDisabled = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the user is disabled";
      };
      enableSharedDeviceControl = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user can control shared devices";
      };
      enableRemoteAccess = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user can access the server remotely";
      };
      enableLiveTvManagement = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user can manage live tv";
      };
      enableLiveTvAccess = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user can access live tv";
      };
      enableMediaPlayback = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user can play media";
      };
      enableAudioPlaybackTranscoding = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the server should transcode audio for the user if requested";
      };
      enableVideoPlaybackTranscoding = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the server should transcode video for the user if requested";
      };
      enableContentDeletion = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the user can delete content";
      };
      enableContentDownloading = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user can download content";
      };
      enableSyncTranscoding = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable sync transcoding for the user";
      };
      enableMediaConversion = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user can do media conversion";
      };
      enableAllDevices = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user has access to all devices";
      };
      enableAllChannels = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user has access to all channels";
      };
      enableAllFolders = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user has access to all folders";
      };
      enablePublicSharing = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable public sharing for the user";
      };
      enableRemoteControlOfOtherUsers = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the user can remotely control other users";
      };
      enablePlaybackRemuxing = mkOption {
        type = types.bool;
        default = true;
        description = "Whether the user is permitted to do playback remuxing";
      };
      forceRemoteSourceTranscoding = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the server should force transcoding on remote connections for the user";
      };
      enableCollectionManagement = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the user can create, modify and delete collections";
      };
      enableSubtitleManagement = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the user can edit subtitles";
      };
      enableLyricManagement = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the user can edit lyrics";
      };
    };
  };
  userOpts = _: {
    options = {
      preferences = mkOption {
        description = "Preferences for this user";
        default = {};
        type = with types; submodule preferenceOpts;
        example = {
          # Whitelist libraries
          enabledLibraries = [
            "TV Shows"
            "Movies"
          ];
        };
      };
      permissions = mkOption {
        description = "Permissions for this user";
        default = {};
        type = with types; submodule permissionOpts;
        example = {
          isAdministrator = true;
          enableContentDeletion = false;
          enableSubtitleManagement = true;
          isDisabled = false;
        };
      };
      mutable = mkOption {
        type = types.bool;
        example = false;
        description = ''
          Functions like mutableUsers in NixOS users.users."user"
          If true, the first time the user is created, all configured options
          are overwritten. Any modifications from the GUI will take priority,
          and no nix configuration changes will have any effect.
          If false however, all options are overwritten as specified in the nix configuration,
          which means any change through the Jellyfin GUI will have no effect after a rebuild.
        '';
        default = true;
      };
      id = mkOption {
        type = types.nullOr types.str; # TODO: Limit the id to the pattern: "18B51E25-33FD-46B6-BBF8-DB4DD77D0679"
        description = "The ID of the user";
        example = "18B51E25-33FD-46B6-BBF8-DB4DD77D0679";
        default = null;
      };
      audioLanguagePreference = mkOption {
        type = with types; nullOr str;
        description = "The audio language preference. Defaults to 'Any Language'";
        default = null;
        example = "eng";
      };
      authenticationProviderId = mkOption {
        type = types.str;
        default = "Jellyfin.Server.Implementations.Users.DefaultAuthenticationProvider";
      };
      displayCollectionsView = mkOption {
        type = types.bool;
        description = "Whether to show the Collections View";
        example = true;
        default = false;
      };
      displayMissingEpisodes = mkOption {
        type = types.bool;
        description = "Whether to show missing episodes";
        example = true;
        default = false;
      };
      enableAutoLogin = mkOption {
        type = types.bool;
        example = true;
        default = false;
      };
      enableLocalPassword = mkOption {
        type = types.bool;
        example = true;
        default = false;
      };
      enableNextEpisodeAutoPlay = mkOption {
        type = types.bool;
        description = "Automatically play the next episode";
        example = false;
        default = true;
      };
      enableUserPreferenceAccess = mkOption {
        type = types.bool;
        example = false;
        default = true;
      };
      hidePlayedInLatest = mkOption {
        type = types.bool;
        description = "Whether to hide already played titles in the 'Latest' section";
        example = false;
        default = true;
      };
      internalId = mkOption {
        type = with types; nullOr int;
        # NOTE: index is 1-indexed! NOT 0-indexed.
        description = "The index of the user in the database. Be careful setting this option. 1 indexed.";
        example = 69;
        default = null;
      };
      loginAttemptsBeforeLockout = mkOption {
        type = types.nullOr types.int;
        description = "The number of login attempts the user can make before they are locked out. 0 for default (3 for normal users, 5 for admins). null for unlimited";
        example = 10;
        default = 3;
      };
      maxActiveSessions = mkOption {
        type = types.int;
        description = "The maximum number of active sessions the user can have at once. 0 for unlimited";
        example = 5;
        default = 0;
      };

      # DEPRECATED: Remove after a while
      maxParentalAgeRating = mkOption {
        type = with types; nullOr int;
        default = null;
        description = ''
          > [!WARNING]
          Deprecated. Use `users.*.maxParentalRatingSubScore` instead.
        '';
      };

      maxParentalRatingSubScore = mkOption {
        type = with types; nullOr int;
        default = null;
      };
      password = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      hashedPassword = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          A pbkdf2-sha512 hash of the users password. Can be generated with the genhash flake app.
          See docs for `HashedPasswordFile` for details on how to generate a hash
        '';
        example = "$PBKDF2-SHA512$iterations=210000$D12C02D1DD15949D867BCA9971BE9987$67E75CDCD14E7F6FDDF96BAACBE9E84E5197FB9FE454FB039F5CD773D7DF558B57DC81DB42B6F7CF0E6B8207A771E5C0EE0DBFD91CE5BAF804FE53F70E61CD2E";
      };
      hashedPasswordFile = mkOption {
        type = types.nullOr types.path;
        description = ''
          A path to a pbkdf2-sha512 hash
          in this format [PHC string](https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md).
          You can use the packaged 'genhash' tool in this flake.nix to generate a hash
          ```
          # default values:
          nix run gitlab:SpoodyTheOne/declarative-jellyfin#genhash -- \\
            -k <password> \\
            -i 210000 \\
            -l 128 \\
            -u
          # Usage:
          nix run gitlab:SpoodyTheOne/declarative-jellyfin#genhash -h

          ```
        '';
        example = ''
          # the format is: $<id>[$<param>=<value>(,<param>=<value>)*][$<salt>[$<hash>]]
          $PBKDF2-SHA512$iterations=210000$D12C02D1DD15949D867BCA9971BE9987$67E75CDCD14E7F6FDDF96BAACBE9E84E5197FB9FE454FB039F5CD773D7DF558B57DC81DB42B6F7CF0E6B8207A771E5C0EE0DBFD91CE5BAF804FE53F70E61CD2E
        '';
        default = null;
      };
      passwordResetProviderId = mkOption {
        type = types.str;
        default = "Jellyfin.Server.Implementations.Users.DefaultPasswordResetProvider";
      };
      playDefaultAudioTrack = mkOption {
        type = types.bool;
        example = false;
        default = true;
      };
      rememberAudioSelections = mkOption {
        type = types.bool;
        default = true;
      };
      rememberSubtitleSelections = mkOption {
        type = types.bool;
        default = true;
      };
      remoteClientBitrateLimit = mkOption {
        type = types.int;
        description = "0 for unlimited";
        default = 0;
      };
      subtitleLanguagePreference = mkOption {
        type = with types; nullOr str;
        description = "The subtitle language preference. Defaults to 'Any Language'";
        example = "eng";
        default = null;
      };
      # https://github.com/jellyfin/jellyfin/blob/master/src/Jellyfin.Database/Jellyfin.Database.Implementations/Enums/SubtitlePlaybackMode.cs
      subtitleMode = mkOption {
        type = types.enum [
          "default"
          "always"
          "onlyForced"
          "none"
          "smart"
        ];
        description = ''
          Default: The default subtitle playback mode.
          Always: Always show subtitles.
          OnlyForced: Only show forced subtitles.
          None: Don't show subtitles.
          Smart: Only show subtitles when the current audio stream is in a different language.
        '';
        default = "default";
      };
      syncPlayAccess = mkOption {
        type = types.bool;
        description = "Whether or not this user has access to SyncPlay";
        example = true;
        default = false;
      };
      # Something to do with chromecast, don't know tbh
      castReceiverId = mkOption {
        type = types.str;
        default = "F007D354";
      };
      invalidLoginAttemptCount = mkOption {
        type = types.int;
        default = 0;
      };
      mustUpdatePassword = mkOption {
        type = types.int;
        default = 0;
      };
      rowVersion = mkOption {
        type = types.int;
        default = 0;
      };
      lastActivityDate = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      lastLoginDate = mkOption {
        type = with types; nullOr str;
        default = null;
      };
    };
  };
in {
  options.services.declarative-jellyfin.
  # Based on: https://github.com/jellyfin/jellyfin/blob/master/MediaBrowser.Model/Configuration/UserConfiguration.cs
  users = mkOption {
    description = "User configuration";
    default = {};
    type = with types; attrsOf (submodule userOpts);
    example = {
      Admin = {
        password = "123";
        maxParentalRatingSubScore = 12;
      };
    };
  };
}
