{pkgs ? import <nixpkgs> {}, ...}: let
  name = "libraries";
  port = 8096;
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    nodes = {
      machine = {...}: {
        imports = [
          ../../modules/default.nix
        ];

        virtualisation.memorySize = 1024;

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

        services.declarative-jellyfin = {
          network.publicHttpPort = port;
          enable = true;
          system.isStartupWizardCompleted = true;
          openFirewall = true;
          users = {
            admin = {
              password = "admin";
              permissions = {
                isAdministrator = true;
              };
            };
          };
          libraries = {
            Movies = {
              enabled = true;
              contentType = "movies";
              pathInfos = ["/data/Movies"];
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
        };
      };
    };

    testScript =
      # py
      ''
        machine.start()
        machine.wait_until_succeeds("curl 127.0.0.1:8096", timeout=300)
        machine.succeed("! journalctl --no-pager -b -u jellyfin.service | grep -v \"plugin\" | grep -q \"ERR\"")
        # TODO: use api key to test that libraries are there
      '';
  };
}
