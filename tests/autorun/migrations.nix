{pkgs ? import <nixpkgs> {}, ...}: let
  name = "migrations";
  port = 8096;
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    nodes = {
      normal = {pkgs, ...}: {
        imports = [
          ../../modules/default.nix
        ];

        virtualisation.memorySize = 1024;
        virtualisation.diskSize = 4096;

        services.jellyfin = {
          enable = true;
        };

        environment.systemPackages = with pkgs; [
          gnutar
        ];
      };

      declarative = {...}: {
        imports = [
          ../../modules/default.nix
        ];

        virtualisation.memorySize = 1024;
        virtualisation.diskSize = 4096;

        services.declarative-jellyfin = {
          enable = true;
          network.publicHttpPort = port;
        };
      };
    };

    testScript =
      # py
      ''
        normal.start()
        normal.wait_for_unit("jellyfin.service")
        # Wait for db to be created
        normal.wait_until_succeeds("test -e /var/lib/jellyfin/data/jellyfin.db", timeout=120)
        # Give jellyfin time to set up
        normal.succeed("sleep 10")

        # stop jellyfin
        normal.execute("systemctl stop jellyfin")

        # Give jellyfin time to stop
        normal.succeed("sleep 10")

        normal.copy_from_vm("/var/lib/jellyfin/", "jellyfin/")

        declarative.copy_from_host(str(driver.out_dir.joinpath("jellyfin/jellyfin/")), "/var/lib/jellyfin")

        normal.shutdown()

        # Test if migrated server boots up
        declarative.wait_until_succeeds("curl 127.0.0.1:${toString port}", timeout=300)
      '';
  };
}
