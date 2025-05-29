{
  pkgs,
  lib,
  ...
}:
with lib; let
  pluginOptions = {
    name,
    config,
    ...
  }: {
    options = {
      name = mkOption {
        type = types.str;
        description = "The name of the plugin";
      };
      url = mkOption {
        type = types.nonEmptyStr;
        description = "Url location of the plugin .zip file";
      };
      version = mkOption {
        type = types.nonEmptyStr;
        description = "Which version of the plugin to download";
        default = "unknown";
      };
      sha256 = mkOption {
        type = types.str;
        description = "sha-256 hash to match against the downloaded files";
      };
      targetAbi = mkOption {
        type = types.str;
        description = "in case a plugin doesnt provide a meta.json file this has to be specified";
        example = "10.10.7.0";
        default = "";
      };
    };
  };
in {
  options.services.declarative-jellyfin.plugins = mkOption {
    type = with types; listOf (submodule pluginOptions);
    default = [
      (import ../../plugins/tvdb.nix (with pkgs; {
        inherit pkgs fetchFromGitHub;
        mkJellyfinPlugin = import ../../plugins {inherit pkgs;};
      }))
    ];
    description = "List of jellyfin plugins";
  };
}
