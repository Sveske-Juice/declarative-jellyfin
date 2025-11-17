pkgs:
pkgs.jellyfin.overrideAttrs (_old: {
  patches = [./remove-size-check.patch];
})
