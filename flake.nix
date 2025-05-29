{
  description = "Declarative jellyfin with more options";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    # Create a test for every file in `tests/`
    tests = system:
      builtins.listToAttrs (builtins.map
        (x: let
          test = import (./tests/autorun + "/${x}") {
            pkgs = import nixpkgs {inherit system;};
          };
        in {
          name = test.name;
          value = test.test;
        })
        (
          builtins.filter (x: x != null) ((nixpkgs.lib.attrsets.mapAttrsToList (name: value:
            if value == "regular"
            then name
            else null))
          (builtins.readDir ./tests/autorun))
        ));
  in {
    formatter = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in
        pkgs.alejandra
    );

    nixosModules = rec {
      declarative-jellyfin = import ./modules;
      default = declarative-jellyfin;
    };

    # Run all tests for all systems
    hydraJobs = forAllSystems tests;
    checks = forAllSystems tests;

    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        genhash = import ./modules/pbkdf2-sha512.nix {inherit pkgs;};
        mkJellyfinPlugin = import ./plugins/default.nix {inherit pkgs;};
      }
    );

    devShell = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [bear gcc nettle];
          nativeBuildInputs = [pkgs.nettle];
        }
    );
  };
}
