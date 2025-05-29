{
  mkJellyfinPlugin,
  fetchFromGitHub,
  ...
}:
mkJellyfinPlugin {
  name = "TheTVDB";
  version = "19.0.0.0";
  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-plugin-tvdb";
    rev = "06f6997fd87a7b60e9a6f4b0831943561e7fc012";
    hash = "sha256-zCpi/u446QsKPRk649EbTBeLwB8m5rFv2+rz0jrZs30=";
  };
  projectFile = "Jellyfin.Plugin.Tvdb.sln";
}
