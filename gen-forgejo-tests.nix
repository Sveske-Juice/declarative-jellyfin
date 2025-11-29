{
  pkgs ? import <nixpkgs>,
  checks,
  ...
}: let
  inherit (pkgs.lib) mapAttrsToList;

  actions = {
    name = "Actions";

    on = [
      "push"
    ];

    jobs = {
      "00_run_tests" = {
        runs-on = "native";
        "if" = "forgejo.actor != 'baritone'";

        steps =
          [
            {
              name = "Checkout";
              uses = "actions/checkout@v3";
            }
            {
              name = "Format Check";
              run = ''
                nix fmt -- --ci
              '';
            }
          ]
          ++ (mapAttrsToList (name: _value: {
              inherit name;
              run = ''
                nix run .#checks.${pkgs.stdenv.hostPlatform.system}.${name}.driver
              '';
              timeout-minutes = 5;
            })
            checks);
      };

      "01_generate_documentation" = {
        runs-on = "native";
        needs = "run_tests";
        "if" = "forge.actor != 'baritone' && forge.ref_name == 'main'";

        steps = [
          {
            name = "Checkout";
            uses = "actions/checkout@v3";
          }
          {
            name = "Generate documentation";
            env."SSH_PRIVATE_KEY" = "$${{ secrets.BARITONE_KEY }}";
            run =
              #bash
              ''
                nix run .#generate-documentation
                git config --local user.name "baritone"
                git config --local user.email "baritone@mail.spoodythe.one"

                git add documentation/*
                git commit -m "chore: Updated DOCUMENTATION.md" || exit 0

                echo "$SSH_PRIVATE_KEY" > /tmp/private_key
                chmod 600 /tmp/private_key
                git config --local core.sshCommand "ssh -i /tmp/private_key -o StrictHostKeyChecking=no"

                git remote remove origin
                git remote add origin forgejo@git.spoodythe.one:spoody/declarative-jellyfin.git

                git push origin main
              '';
          }
        ];
      };
    };
  };
in
  (pkgs.runCommand "toYAML" {
    buildInputs = with pkgs; [yj];
    json = builtins.toJSON actions;
    passAsFile = ["json"]; # will be available as `$jsonPath`
  })
  ''
    yj -jy < "$jsonPath" > $out
  ''
