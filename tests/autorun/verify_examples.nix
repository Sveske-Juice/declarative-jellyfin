{pkgs ? import <nixpkgs> {}, ...}: let
  name = "verify-examples";
  exampleFiles = map (file: pkgs.lib.strings.removeSuffix ".nix" file) (
    builtins.attrNames (builtins.readDir ../../examples)
  );
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    # Generate a VM Node foreach example file config
    nodes = pkgs.lib.attrsets.genAttrs exampleFiles (
      example: {...}: {
        imports = [
          ../../modules/default.nix
          (import (../../examples + "/${example}.nix") {})
        ];

        virtualisation.memorySize = 1024;
      }
    );

    # Run the same test on each node VM
    testScript =
      # py
      ''
        start_all()

        # Wait foreach node to run jellyfin-init
        for node in machines:
          node.wait_until_succeeds("test -e /var/log/jellyfin-init-done", timeout=120)

        # Give 10 seconds for jellyfin to boot
        for node in machines:
          node.wait_until_succeeds("curl 127.0.0.1:8096", timeout=60)

        # No errors should be reported in journal
        for node in machines:
          node.succeed("! journalctl --no-pager -b -u jellyfin.service | grep -v \"plugin\" | grep -q \"ERR\"")

        for node in machines:
          print("[" + node.succeed("hostname").strip() + "] " + "Jellyfin log: " + node.succeed("journalctl --no-pager -b -u jellyfin.service"))
      '';
  };
}
