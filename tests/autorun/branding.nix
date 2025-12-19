{pkgs ? import <nixpkgs> {}, ...}: let
  name = "branding";

  loginDisclaimer = "LOGIN DISCLAIMER LOGIN DISCLAIMER LOGIN DISCLAIMER";
  port = 8096;
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    nodes = {
      machine = {pkgs, ...}: {
        virtualisation.memorySize = 2048; # 2gb

        imports = [
          ../../modules/default.nix
        ];

        environment.systemPackages = [
          pkgs.firefox
        ];

        services.declarative-jellyfin = {
          enable = true;
          network.publicHttpPort = port;
          branding = {
            inherit loginDisclaimer;
            customCss =
              # css
              ''
                * {
                  color: red !important;
                }
              '';
            splashscreenEnabled = true;
          };
        };

        users.users.test = {
          isNormalUser = true;
        };

        services.xserver.windowManager.i3.enable = true;
        services.xserver.enable = true;
        services.displayManager.autoLogin.enable = true;
        services.displayManager.autoLogin.user = "test";
      };
    };

    enableOCR = true;

    testScript =
      # py
      ''
        machine.start()
        machine.wait_for_unit("multi-user.target");
        machine.wait_for_unit("graphical.target");
        machine.send_key("esc") # close i3 popup
        machine.wait_for_console_text(".Jellyfin terminated. Resetting with IsStartupWizardCompleted set to true")
        machine.wait_for_console_text("Emby.Server.Implementations.ApplicationHost: Core startup complete")
        machine.execute("sudo -u test firefox localhost:${toString port} >&2>/dev/null &")
        machine.wait_for_text("Please sign in")
        machine.wait_for_text("${loginDisclaimer}")
      '';
  };
}
