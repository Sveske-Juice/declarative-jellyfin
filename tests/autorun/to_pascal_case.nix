{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  name = "to_pascal_test";
in
{
  inherit name;
  # TODO: Move this out of a vm. it just needs to be an evaluation time assertion
  test = pkgs.nixosTest {
    inherit name;
    nodes = {
      machine =
        {
          config,
          pkgs,
          ...
        }:
        {
          assertions =
            let
              genTest = name: expected: got: {
                assertion = expected == got;
                message = "[Test: ${name}] Converted string is incorrect!\nExpected \n\n${expected}\n but got \n\n${got}";
              };
              toPascalCase = (import ../../lib { nixpkgs = pkgs; }).toPascalCase;
            in
            [
              (genTest "from kebab case" "ThisIsKebabCase" (toPascalCase.fromString "this-is-kebab-case"))
              (genTest "from camel case" "ThisIsCamelCase" (toPascalCase.fromString "thisIsCamelCase"))
              (genTest "from pascal case" "ThisIsPascalCase" (toPascalCase.fromString "ThisIsPascalCase"))
              (genTest "from snake case" "ThisIsSnakeCase" (toPascalCase.fromString "this_is_snake_case"))
              (genTest "empty string" "" (toPascalCase.fromString ""))
              (genTest "from string with digits" "EnableDecodingColorDepth10Hevc" (
                toPascalCase.fromString "enableDecodingColorDepth10Hevc"
              ))
              (genTest "kebab case attribute set" {
                KebabCaseName = "kebab-case-value";
              } (toPascalCase.fromAttrs { kebab-case-name = "kebab-case-value"; }))
              (genTest "camel case attribute set" {
                CamelCaseName = "camelCaseValue";
              } (toPascalCase.fromAttrs { camelCaseName = "camelCaseValue"; }))
              (genTest "snake case attribute set" {
                SnakeCaseName = "snake_case_value";
              } (toPascalCase.fromAttrs { snake_case_name = "snake_case_value"; }))
              # TODO: TODO
              (genTest "recursive attret test" "TODO" "TODO")
              (genTest "attribute set with list"
                {
                  List = [
                    { ListItem = "listValue"; }
                    { ListItem = "listValue"; }
                  ];
                }
                (
                  toPascalCase.fromAttrsRecursive {
                    list = [
                      { listItem = "listValue"; }
                      { listItem = "listValue"; }
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
