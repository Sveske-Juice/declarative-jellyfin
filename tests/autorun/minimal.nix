{pkgs ? import <nixpkgs> {}, ...}: let
  name = "minimal";
  port = 8096;
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    nodes = {
      machine = {config,...}: {
        imports = [
          ../../modules/default.nix
        ];

        virtualisation.memorySize = 1024;

        # Doesn't get more minimal than this
        services.declarative-jellyfin = {
          enable = true;
          network.publicHttpPort = port;
        };
      };
    };

    testScript =
      # py
      ''
        print(machine.execute("sleep 10 && cat /etc/tmpfiles.d/jellyfinDirs.conf")[1])
        print(machine.execute("ls -la /var/lib/jellyfin")[1])
        print(machine.execute("ls -la /etc/tmpfiles.d")[1])
        machine.wait_for_unit("jellyfin.service")
        machine.succeed("ls -la /var/lib/jellyfin")
        # Make sure no errors are happening while jellyfin starts up
        # we ignore download plugin errors
        for i in range(10):
          machine.succeed("! journalctl --no-pager -b -u jellyfin.service | grep -v \"plugin\" | grep -q \"ERR\"")
          machine.succeed("sleep 1")

        # print log for debugging
        print(machine.execute("journalctl --no-pager -b -u jellyfin.service")[1])

        # Should be able to curl it
        machine.succeed("curl 127.0.0.1:${toString port}")
      '';
  };
}
