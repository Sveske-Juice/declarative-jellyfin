{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  name = "minimal";

  loginDisclaimer = "LOGIN DISCLAIMER LOGIN DISCLAIMER LOGIN DISCLAIMER";
in
{
  inherit name;
  test = pkgs.nixosTest {
    inherit name;
    nodes = {
      machine =
        {
          config,
          pkgs,
          ...
        }:
        {
          imports = [
            ../../modules/default.nix
          ];

          environment.systemPackages = [
            pkgs.firefox
          ];

          services.declarative-jellyfin = {
            enable = true;
            branding = {
              inherit loginDisclaimer;
              customCSS =
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
          services.xserver.displayManager.autoLogin.enable = true;
          services.xserver.displayManager.autoLogin.user = "test";
        };
    };

    testScript =
      # py
      ''
        machine.start()
        machine.wait_for_unit("multi-user.target");
        machine.wait_for_unit("jellyfin.service");
        machine.wait_for_unit("graphical.target");
        machine.succeed("firefox")
      '';
  };
}
