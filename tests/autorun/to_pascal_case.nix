{pkgs ? import <nixpkgs> {}, ...}: let
  name = "to_pascal_test";
in {
  inherit name;
  # TODO: Move this out of a vm. it just needs to be an evaluation time assertion
  test = pkgs.nixosTest {
    inherit name;
    nodes = {
      machine = {pkgs, ...}: {
        assertions = let
          genTest = name: expected: got: {
            assertion = expected == got;
            message = "[Test: ${name}] Converted string is incorrect!\nExpected \n\n${expected}\n but got \n\n${got}";
          };
          inherit ((import ../../lib {nixpkgs = pkgs;})) toPascalCase;
        in [
          (genTest "from kebab case" "ThisIsKebabCase" (toPascalCase.fromString "this-is-kebab-case"))
          (genTest "from camel case" "ThisIsCamelCase" (toPascalCase.fromString "thisIsCamelCase"))
          (genTest "from camel case acronym IPv6" "EnableIPv6" (toPascalCase.fromString "enableIPv6"))
          (genTest "from camel case acronym UPnP" "EnableUPnP" (toPascalCase.fromString "enableUPnP"))
          (genTest "from pascal case" "ThisIsPascalCase" (toPascalCase.fromString "ThisIsPascalCase"))
          (genTest "from snake case" "ThisIsSnakeCase" (toPascalCase.fromString "this_is_snake_case"))
          (genTest "empty string" "" (toPascalCase.fromString ""))
          (genTest "from string with digits" "EnableDecodingColorDepth10Hevc" (
            toPascalCase.fromString "enableDecodingColorDepth10Hevc"
          ))
          (genTest "kebab case attribute set" {
            KebabCaseName = "kebab-case-value";
          } (toPascalCase.fromAttrs {kebab-case-name = "kebab-case-value";}))
          (genTest "camel case attribute set" {
            CamelCaseName = "camelCaseValue";
          } (toPascalCase.fromAttrs {camelCaseName = "camelCaseValue";}))
          (genTest "snake case attribute set" {
            SnakeCaseName = "snake_case_value";
          } (toPascalCase.fromAttrs {snake_case_name = "snake_case_value";}))

          # Ensures structural keys are preserved (tag/content/attrib),
          # while inner data keys are PascalCased.
          (
            genTest "preserve structural keys + pascalcase data"
            {
              tag = "RepositoryInfo";
              content = {
                Name = "Jellyfin test";
                Url = "https://repo.jellyfin.org/files/plugin/manifest.json";
                Enabled = true;
              };
              attrib = {
                SomeAttr = "value";
              };
            }
            (
              toPascalCase.fromAttrsRecursive {
                tag = "RepositoryInfo";
                content = {
                  name = "Jellyfin test";
                  url = "https://repo.jellyfin.org/files/plugin/manifest.json";
                  enabled = true;
                };
                attrib = {
                  some_attr = "value";
                };
              }
            )
          )

          # Sanity: a fully structured XML-like tree remains unchanged by renamer
          # (no accidental Tag/Content/Attrib renames).
          (
            genTest "no rename of structured xml nodes"
            {
              tag = "PluginRepositories";
              content = [
                {
                  tag = "RepositoryInfo";
                  content = [
                    {
                      tag = "Name";
                      content = "Jellyfin test";
                    }
                    {
                      tag = "Url";
                      content = "https://repo.jellyfin.org/files/plugin/manifest.json";
                    }
                    {
                      tag = "Enabled";
                      content = true;
                    }
                  ];
                }
              ];
            }
            (
              toPascalCase.fromAttrsRecursive {
                tag = "PluginRepositories";
                content = [
                  {
                    tag = "RepositoryInfo";
                    content = [
                      {
                        tag = "Name";
                        content = "Jellyfin test";
                      }
                      {
                        tag = "Url";
                        content = "https://repo.jellyfin.org/files/plugin/manifest.json";
                      }
                      {
                        tag = "Enabled";
                        content = true;
                      }
                    ];
                  }
                ];
              }
            )
          )

          (
            genTest "attribute set with list"
            {
              List = [
                {ListItem = "listValue";}
                {ListItem = "listValue";}
              ];
            }
            (
              toPascalCase.fromAttrsRecursive {
                list = [
                  {listItem = "listValue";}
                  {listItem = "listValue";}
                ];
              }
            )
          )
        ];
      };
    };

    testScript = "";
  };
}
