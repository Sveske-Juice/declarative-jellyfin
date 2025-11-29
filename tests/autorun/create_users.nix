{pkgs ? import <nixpkgs> {}, ...}: let
  name = "createusers";
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    nodes = {
      machine = {pkgs, ...}: {
        imports = [
          ../../modules/default.nix
        ];

        virtualisation.memorySize = 1024;

        environment.systemPackages = with pkgs; [
          sqlite
          file
        ];

        services.declarative-jellyfin = {
          enable = true;
          package = import ../../patched-jellyfin.nix pkgs;
          users = {
            Admin = {
              mutable = false;
              password = "123";
              permissions = {
                isAdministrator = true;
                isDisabled = false;
                # ...
              };
            };
            "Some cool user with spaces" = {
              mutable = true;
              hashedPasswordFile = ../example_hash.txt;
            };
            alice = {
              hashedPassword = "$PBKDF2-SHA512$iterations=210000$D12C02D1DD15949D867BCA9971BE9987$67E75CDCD14E7F6FDDF96BAACBE9E84E5197FB9FE454FB039F5CD773D7DF558B57DC81DB42B6F7CF0E6B8207A771E5C0EE0DBFD91CE5BAF804FE53F70E61CD2E";
            };
          };
        };
      };
    };

    testScript =
      # py
      ''
        machine.start()
        machine.wait_until_succeeds("test -e /var/lib/jellyfin/init-done", timeout=300)
        machine.wait_until_succeeds("curl 127.0.0.1:8096", timeout=120)
        output = machine.succeed("cat /var/log/jellyfin.txt")
        print("Log: " + output)
        users = machine.succeed("sqlite3 /var/lib/jellyfin/data/jellyfin.db -- \"SELECT * FROM Users\"")
        print("Users: " + users)

        # TODO: loop over and check for every user
        if machine.succeed("sqlite3 /var/lib/jellyfin/data/jellyfin.db -- \"SELECT * FROM Users WHERE Username = 'Admin'\"") == "":
          assert False, "User not in db"
      '';
  };
}
