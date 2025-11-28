pkgs:
pkgs.jellyfin.overrideAttrs (
  _old: let
    lock = builtins.fromJSON (builtins.readFile ./jellyfin-lock.json);
  in {
    inherit (lock) version;
    src = pkgs.fetchFromGitHub lock.src;
    patches = [./remove-size-check.patch];
  }
)
