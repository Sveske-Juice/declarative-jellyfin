{
  description = "Declarative jellyfin with more options";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    nixpkgs,
    systems,
    treefmt-nix,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);

    eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

    # Create a test for every file in `tests/`
    tests = system:
      builtins.listToAttrs (
        builtins.map
        (
          x: let
            test = import (./tests/autorun + "/${x}") {
              pkgs = import nixpkgs {inherit system;};
            };
          in {
            inherit (test) name;
            value = test.test;
          }
        )
        (
          builtins.filter (x: x != null) (
            (nixpkgs.lib.attrsets.mapAttrsToList (name: value:
              if value == "regular"
              then name
              else null)) (
              builtins.readDir ./tests/autorun
            )
          )
        )
      );
  in {
    # for `nix fmt`
    formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

    nixosModules = rec {
      declarative-jellyfin = import ./modules;
      default = declarative-jellyfin;
    };

    # Run all tests for all systems
    hydraJobs = forAllSystems tests;
    checks = forAllSystems tests;

    apps = eachSystem (pkgs: {
      generate-documentation = {
        type = "app";
        program = builtins.toString (
          import ./documentation.nix {
            inherit pkgs;
            inherit (pkgs) lib writeTextFile writeShellScript;
          }
        );
      };
    });

    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        genhash = import ./modules/pbkdf2-sha512.nix {inherit pkgs;};
      }
    );

    devShell = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            bear
            gcc
            nettle
          ];
          nativeBuildInputs = [pkgs.nettle];
        }
    );
  };
}
