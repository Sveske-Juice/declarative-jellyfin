{pkgs ? import <nixpkgs> {}, ...}: let
  name = "minimal";
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    nodes = {
      machine = {...}: {
        imports = [
          ../modules/default.nix
        ];

        services.jellyfin.enable = true;

        virtualisation.memorySize = 1024;
      };
    };

    testScript =
      # py
      ''
        machine.start()
        machine.wait_for_unit("multi-user.target");
        machine.wait_for_unit("jellyfin.service");
        machine.wait_for_file("/var/lib/jellyfin/data/jellyfin.db", 60)
        machine.succeed("sleep 10")
        machine.systemctl("stop jellyfin.service")
        machine.wait_until_fails("pgrep jellyfin")
        machine.copy_from_vm("/var/lib/jellyfin/data/jellyfin.db", "jellyfin.db")
      '';
  };
}
