{lib, ...}:
with lib; {
  options.services.declarative-jellyfin.branding = {
    loginDisclaimer = mkOption {
      type = with types; lines;
      default = "";
      description = ''
        Sets the text shown during login underneath the form.
      '';
    };
    customCss = mkOption {
      type = with types; lines;
      default = "";
      description = ''
        Custom css to be injected into the web client.
      '';
    };
    # TODO: Move to splashscreen attribute and transform to this form in config.nix
    splashscreenEnabled = mkOption {
      type = with types; bool;
      default = false;
      description = ''
        Enables a splashscreen to be shown during loading.
      '';
    };
    splashscreenLocation = mkOption {
      type = with types; either path str;
      default = "";
      description = ''
        Location of the splashscreen image
      '';
    };
  };
}
