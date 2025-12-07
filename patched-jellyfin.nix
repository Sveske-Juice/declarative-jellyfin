pkgs:
pkgs.jellyfin.overrideAttrs (
  _old: let
    lock = builtins.fromJSON (builtins.readFile ./jellyfin-lock.json);
  in {
    inherit (lock) version;
    src = pkgs.fetchFromGitHub {
      owner = "jellyfin";
      repo = "jellyfin";
      tag = "v${lock.version}";
      inherit (lock) hash;
    };
    patches = [./remove-size-check.patch];
  }
)
