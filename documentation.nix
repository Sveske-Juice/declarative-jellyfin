{
  pkgs,
  lib,
  writeTextFile,
  writeShellScript,
  ...
}: let
  modules = [
    {
      name = "system";
      options =
        (import ./modules/options/system.nix {
          inherit lib;
          config = {
            networking.hostName = "config.networking.hostName";
          };
        })
        .options
        .services
        .declarative-jellyfin
        .system;
    }
    {
      name = "libraries";
      options =
        (import ./modules/options/libraries.nix {
          inherit lib;
          config = {
            networking.hostName = "config.networking.hostName";
          };
        })
        .options
        .services
        .declarative-jellyfin
        .libraries;
    }
    {
      name = "encoding";
      options =
        (import ./modules/options/encoding.nix {
          inherit lib pkgs;
          config = {
            networking.hostName = "config.networking.hostName";
          };
        })
        .options
        .services
        .declarative-jellyfin
        .encoding;
    }
    {
      name = "network";
      options =
        (import ./modules/options/network.nix {
          inherit lib pkgs;
          config = {
            networking.hostName = "config.networking.hostName";
          };
        })
        .options
        .services
        .declarative-jellyfin
        .network;
    }
    {
      name = "users";
      options =
        (import ./modules/options/users.nix {
          inherit lib pkgs;
          config = {
            networking.hostName = "config.networking.hostName";
          };
        })
        .options
        .services
        .declarative-jellyfin
        .users;
    }
    {
      name = "branding";
      options =
        (import ./modules/options/branding.nix {
          inherit lib pkgs;
          config = {
            networking.hostName = "config.networking.hostName";
          };
        })
        .options
        .services
        .declarative-jellyfin
        .branding;
    }
  ];

  inherit (lib) attrsets;
  inherit (lib) trivial;
  repeat' = t: c: i:
    if i <= 0
    then t
    else repeat' (t + c) c (i - 1);
  repeat = repeat' "";

  toStringDoc' = depth: let
    d0 = x:
      if depth == 0
      then x
      else "";
  in
    value:
      if builtins.isString value
      then
        # TODO: Prettier multiline strings
        "${d0 "`"}\"${value}\"${d0 "`"}"
      else if builtins.isBool value
      then "${d0 "`"}${trivial.boolToString value}${d0 "`"}"
      else if builtins.isInt value || builtins.isFloat value
      then "${d0 "`"}${toString value}${d0 "`"}"
      else if builtins.isList value
      then
        if builtins.length value == 0
        then "${d0 "`"}[]${d0 "`"}"
        else ''
          ${d0 ''

            ```nix
          ''}[
          ${builtins.concatStringsSep "\n" (
            builtins.map (x: (repeat " " (depth + 1)) + (toStringDoc' (depth + 1) x)) value
          )}
          ${repeat " " depth}]${d0 "\n```"}''
      else if builtins.isAttrs value
      then ''
        ${d0 ''

          ```nix
        ''}{
        ${builtins.concatStringsSep "\n" (
          attrsets.mapAttrsToList (
            k: v: "${repeat " " (depth + 1)}${k} = ${toStringDoc' (depth + 1) v};"
          )
          value
        )}
        ${repeat " " depth}}${d0 "\n```"}''
      else "`<${builtins.typeOf value}>`";
  toStringDoc = toStringDoc' 0;

  isOr = set: attr: y: n: (
    if builtins.hasAttr attr set
    then y set.${attr}
    else n
  );

  makeDocumentationRecursive = depth: fqn: option:
    "${repeat "#" (depth + 1)} ${fqn}\n"
    + (
      if builtins.hasAttr "_type" option
      then
        if option.type.name == "attrsOf"
        then
          makeDocumentationRecursive (depth + 1) "${fqn}.\*" (
            builtins.removeAttrs (option.type.nestedTypes.elemType.getSubOptions {}) ["_module"]
          )
        else if option.type.name == "submodule"
        then
          builtins.concatStringsSep "\n" (
            attrsets.mapAttrsToList (k: v: makeDocumentationRecursive (depth + 1) "${fqn}.${k}" v) (
              builtins.removeAttrs (option.type.getSubOptions {}) ["_module"]
            )
          )
        else ''
          ${isOr option "description" (d: d + "\n") ""}
          **Type**: ${option.type.description}
          ${
            let
              default = isOr option "defaultText" (d: "\n**Default**: `${d}`") (
                isOr option "default" (d: "\n**Default**: ${toStringDoc d}") ""
              );
            in
              default
          }
        ''
      else
        builtins.concatStringsSep "\n" (
          attrsets.mapAttrsToList (k: v: makeDocumentationRecursive (depth + 1) "${fqn}.${k}" v) option
        )
    );

  mkModuleFile = module:
    writeTextFile {
      name = "documentation-${module.name}.md";
      text = makeDocumentationRecursive 0 module.name module.options;
    };

  documentationIndex = writeTextFile {
    name = "documentation.md";
    text = ''
      # Automatically generated documentation
      Automatically generated documentation for declarative-jellyfin options

      ${makeDocumentationRecursive 0 "services.declarative-jellyfin"
        (import ./modules/options/default.nix {
          inherit lib pkgs;
          config = {
            services.declarative-jellyfin.dataDir = "$${cfg.dataDir}";
          };
        })
        .options
        .services
        .declarative-jellyfin}

      ${builtins.foldl' (
          a: b:
            a
            + ''
              # ${b.name}
              Options for [services.declarative-jellyfin.${b.name}](https://github.com/Sveske-Juice/declarative-jellyfin/blob/main/documentation/${b.name}.md)

            ''
        ) ""
        modules}
    '';
  };
in
  writeShellScript "generate-documentation" (
    builtins.foldl' (a: b: a + "cp ${mkModuleFile b} ./documentation/${b.name}.md\n") ''
      rm -rf ./documentation/*
      mkdir -p ./documentation/
      cp ${documentationIndex} ./documentation/documentation.md
    ''
    modules
  )
