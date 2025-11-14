{nixpkgs, ...}: let
  inherit (nixpkgs) lib;
in
  with lib; {
    toXMLGeneric = let
      toXMLRecursive = toXmlRecursive' "<?xml version='1.0' encoding='utf-8'?>\n" 0;

      indent = depth: (
        if (depth <= 0)
        then ""
        else ("  " + (indent (depth - 1)))
      );

      toXmlRecursive' = str: depth: xml: let
        parseTag = str: depth: xml: (builtins.concatStringsSep "" [
          str
          "${indent depth}<${xml.tag}${
            if (builtins.hasAttr "attrib" xml)
            then " ${builtins.concatStringsSep " " (
              attrsets.mapAttrsToList (name: value: "${name}=\"${strings.escapeXML value}\"") xml.attrib
            )}"
            else ""
          }${
            if
              !(builtins.hasAttr "content" xml)
              || ((builtins.isString xml.content) && xml.content == "")
              || ((builtins.isList xml.content) && xml.content == [])
            then " />"
            else ">${(toXmlRecursive' "\n" (depth + 1) xml.content)}</${xml.tag}>"
          }"
        ]);
      in
        if (builtins.isAttrs xml)
        then "${parseTag str depth xml}\n${indent (depth - 1)}"
        else if (builtins.isList xml)
        then "\n${
          (builtins.concatStringsSep "" (builtins.map (x: (toXmlRecursive' "" depth x)) xml))
        }${indent (depth - 1)}"
        else if ((builtins.isInt xml) || (builtins.isNull xml) || (builtins.isFloat xml))
        then (builtins.toString xml)
        else if (builtins.isString xml)
        then nixpkgs.lib.strings.escapeXML xml
        else if (builtins.isBool xml)
        then
          if xml
          then "true"
          else "false"
        else throw "Cannot convert a ${builtins.typeOf xml} to XML. ${toString (builtins.trace xml xml)}";
    in
      toXMLRecursive;
    toPascalCase = let
      toPascalCase = parts:
        builtins.foldl' (a: b: a + b) "" (
          builtins.map (
            part: let
              firstChar = builtins.substring 0 1 part;
              rest = builtins.substring 1 ((builtins.stringLength part) - 1) part;
            in
              # If part is entirely lowercase, capitalize first letter
              # Otherwise, preserve the part's original casing
              if part == lib.strings.toLower part
              then "${lib.strings.toUpper firstChar}${rest}"
              else part
          )
          parts
        );
    in rec {
      fromString = x:
        toPascalCase (
          builtins.concatLists (
            builtins.filter builtins.isList (builtins.split "([[:upper:]]+[[:lower:]]+|[[:upper:]]|[[:lower:]]+|[[:digit:]]+)" x)
          )
        );
      # Recursively renames attributes to PascalCase
      fromAttrs' = f: x:
        if builtins.isAttrs x
        then
          lib.attrsets.mapAttrs' (
            name: value: let
              isReserved = lib.elem name [
                "tag"
                "content"
                "attrib"
              ];
              newName =
                if isReserved
                then name
                else fromString name;
            in
              lib.attrsets.nameValuePair newName (f value)
          )
          x
        else if builtins.isList x
        then builtins.map f x
        else x;
      fromAttrs = fromAttrs' (x: x);
      fromAttrsRecursive = fromAttrs' fromAttrsRecursive;
    };
  }
