{lib, ...}:
with lib; let
  pluginOptions = _: {
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
      {
        name = "TheTVDB";
        url = "https://repo.jellyfin.org/files/plugin/thetvdb/thetvdb_19.0.0.0.zip";
        version = "19.0.0.0";
        sha256 = "sha256-3eVUtMgYggBB9S96S7AKsaPhinRiOztGOEEEGQcASws=";
      }
      {
        name = "Webhook";
        version = "17.0.0.0";
        url = "https://repo.jellyfin.org/files/plugin/webhook/webhook_17.0.0.0.zip";
        targetAbi = "10.10.6.0";
        sha256 = "sha256:1y4b4jwp8rrblynlaj4k3qzgv09g6y6sqn6qnkv822w4ndnfhiss";
      }
      {
        name = "Subtitle Extract";
        version = "4.0.0.0";
        url = "https://repo.jellyfin.org/files/plugin/subtitle-extract/subtitle-extract_4.0.0.0.zip";
        targetAbi = "10.9.0.0";
        sha256 = "sha256:1v8ng5g92x18981qkwkvlpfpzim2m3sbjcgcpv7xyw0dyhvrg2m4";
      }
      {
        name = "Chapter Segments Provider";
        version = "3.0.0.0";
        url = "https://repo.jellyfin.org/files/plugin/chapter-segments-provider/chapter-segments-provider_3.0.0.0.zip";
        targetAbi = "10.10.0.0";
        sha256 = "sha256:161cfzdj31cmqlj3nfhzg46b3gnr5hj7p872ifnsykf1g8s14k02";
      }
      {
        name = "IMVDb";
        version = "4.0.0.0";
        url = "https://repo.jellyfin.org/files/plugin/imvdb/imvdb_4.0.0.0.zip";
        targetAbi = "10.9.0.0";
        sha256 = "sha256:1vkzcr0f107vrmd0y3x2ffflxjkck2507ivaxjx7g0xyg9hxhkj1";
      }
    ];
    description = "List of jellyfin plugins";
  };
}
