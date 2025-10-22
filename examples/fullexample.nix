_: {
  services.declarative-jellyfin = {
    enable = true;
    serverId = "f4655afd22f348e19089c6b474b24a73";

    libraries = {
      Movies = {
        enabled = true;
        contentType = "movies";
        pathInfos = ["/data/Movies"];
        typeOptions.Movies = {
          metadataFetchers = [
            "The Open Movie Database"
            "TheMovieDb"
          ];
          imageFetchers = [
            "The Open Movie Database"
            "TheMovieDb"
          ];
        };
      };
      Shows = {
        enabled = true;
        contentType = "tvshows";
        pathInfos = ["/data/Shows"];
      };
      "Photos and videos" = {
        enabled = true;
        contentType = "homevideos";
        pathInfos = [
          "/data/Pictures"
          "/data/Videos"
        ];
      };
      Books = {
        enabled = true;
        contentType = "books";
        pathInfos = ["/data/Books"];
      };
      Music = {
        enabled = true;
        contentType = "music";
        pathInfos = ["/data/Music"];
      };
    };

    users = {
      Admin = {
        mutable = false;
        password = "123";
        permissions = {
          isAdministrator = true;
        };
      };
      Alice = {
        mutable = false;
        hashedPassword = builtins.readFile ../tests/example_hash.txt;
        permissions = {
          isAdministrator = true;
          enableAllFolders = false;
        };
        preferences = {
          # Only allow access to photos and music
          enabledLibraries = [
            "Photos and Videos"
            "Music"
          ];
        };
      };
      Bob = {
        mutable = false;
        hashedPasswordFile = ../tests/example_hash.txt;
        permissions = {
          isAdministrator = false;
        };
      };
    };

    apikeys = {
      Jellyseerr = {
        key = "78878bf9fc654ff78ae332c63de5aeb6";
      };
      Homarr = {
        keyPath = ../tests/example_apikey.txt;
      };
    };

    # TODO: add more
  };

  # This is just for making sure the library paths exists, you dont need this
  system.activationScripts.setupFolders =
    # bash
    ''
      mkdir -p /data/Movies
      mkdir -p /data/Shows
      mkdir -p /data/Pictures
      mkdir -p /data/Videos
      mkdir -p /data/Books
      mkdir -p /data/Music
    '';
}
