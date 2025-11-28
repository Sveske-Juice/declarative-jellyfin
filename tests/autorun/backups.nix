{pkgs ? import <nixpkgs> {}, ...}: let
  name = "backups";
  port = 8096;
  backupDir = "/var/lib/jellyfin/backups";
  backupCount = 2;
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    nodes = {
      ${name} = {...}: {
        imports = [
          ../../modules/default.nix
        ];

        virtualisation.memorySize = 1024;

        services.declarative-jellyfin = {
          enable = true;
          package = import ../../patched-jellyfin.nix pkgs;
          network.publicHttpPort = port;
          backups = true;
          inherit backupDir;
          inherit backupCount;
        };
      };
    };

    testScript =
      # py
      ''
        start_all()

        for node in machines:
          node.wait_until_succeeds("test -e /var/log/jellyfin-init-done", timeout=120)
          node.wait_for_console_text("Main: Startup complete") # later calls will catch this and fail test unless its also here

        # Make sure they created 1 backup
        for node in machines:
          print("backups: " + node.succeed("ls -la \"${backupDir}\""))
          node.succeed("test $(ls -1 \"${backupDir}\" | wc -l) -eq 1")

        # Restart and see if another is created
        for node in machines:
          node.succeed("sleep 45")
          node.succeed("systemctl restart jellyfin")
          # init tag should be removed
          node.succeed("! test -e /var/log/jellyfin-init-done")

        for node in machines:
          node.wait_until_succeeds("test -e /var/log/jellyfin-init-done", timeout=120)

        # Make sure 2nd is created
        for node in machines:
          print("backups: " + node.succeed("ls -la \"${backupDir}\""))
          node.succeed("test $(ls -1 \"${backupDir}\" | wc -l) -eq 2")

        # Make sure backups are rotated
        for node in machines:
          node.succeed("sleep 45")
          node.succeed("systemctl restart jellyfin")
          # init tag should be removed
          node.succeed("! test -e /var/log/jellyfin-init-done")

        for node in machines:
          node.wait_until_succeeds("test -e /var/log/jellyfin-init-done", timeout=120)

        # Should still only be 2 backups
        for node in machines:
          print("backups: " + node.succeed("ls -la \"${backupDir}\""))
          node.succeed("test $(ls -1 \"${backupDir}\" | wc -l) -eq ${toString backupCount}")
      '';
  };
}
