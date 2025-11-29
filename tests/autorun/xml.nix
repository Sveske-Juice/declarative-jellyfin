{pkgs ? import <nixpkgs> {}, ...}: let
  name = "xmltests";
  configs = {
    system = "/var/lib/jellyfin/config/system.xml";
    network = "/var/lib/jellyfin/config/network.xml";
    encoding = "/var/lib/jellyfin/config/encoding.xml";
  };
in {
  inherit name;
  test = pkgs.testers.nixosTest {
    inherit name;
    nodes = {
      machine = {pkgs, ...}: {
        imports = [
          ../../modules/default.nix
        ];
        environment.systemPackages = [pkgs.xmlstarlet];

        # assertions = let
        #   toXml = (import ../lib {nixpkgs = pkgs;}).toXMLGeneric;
        # in [
        #   (
        #     let
        #       xml =
        #         toXml {tag = "test";};
        #       expected = ''
        #         <?xml version='1.0' encoding='utf-8'?>
        #         <test />
        #       '';
        #     in {
        #       assertion = xml == expected;
        #       message = "Generated XML is incorrect!\nExpected \n\n${expected}\n\n but got \n\n${xml}\n";
        #     }
        #   )
        # ];

        assertions = let
          genTest = name: expected: got: {
            assertion = expected == got;
            message = "[Test: ${name}] Generated XML is incorrect!\nExpected \n\n${expected}\n but got \n\n${got}";
          };
          toXml = (import ../../lib {nixpkgs = pkgs;}).toXMLGeneric;
        in [
          (
            genTest "Single tag"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <test />
            ''
            (toXml {
              tag = "test";
            })
          )
          (
            genTest "Single inner tag"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <test>
                <inner />
              </test>
            ''
            (toXml {
              tag = "test";
              content = {
                tag = "inner";
              };
            })
          )
          (
            genTest "Tag with string"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <test>stringstringstring</test>
            ''
            (toXml {
              tag = "test";
              content = "stringstringstring";
            })
          )
          (
            genTest "Empty string"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <test />
            ''
            (toXml {
              tag = "test";
              content = "";
            })
          )
          (
            genTest "List of tags"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <test>
                <tag0 />
                <tag1 />
                <tag2 />
                <tag3 />
                <tag4 />
                <tag5 />
                <tag6 />
                <tag7 />
                <tag8 />
              </test>
            ''
            (toXml {
              tag = "test";
              content = builtins.genList (x: {tag = "tag${toString x}";}) 9;
            })
          )
          (
            genTest "Empty list"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <test />
            ''
            (toXml {
              tag = "test";
              content = [];
            })
          )
          (
            genTest "bool value true"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <test>true</test>
            ''
            (toXml {
              tag = "test";
              content = true;
            })
          )
          (
            genTest "bool value false"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <test>false</test>
            ''
            (toXml {
              tag = "test";
              content = false;
            })
          )
          (
            genTest "tags with attrib should close after attrib"
            ''
              <?xml version='1.0' encoding='utf-8'?>
              <LibraryOptions xmlns:xsd="http://www.w3.org/2001/XMLSchema">test</LibraryOptions>
            ''
            (toXml {
              tag = "LibraryOptions";
              attrib = {
                "xmlns:xsd" = "http://www.w3.org/2001/XMLSchema";
              };
              content = "test";
            })
          )
        ];

        virtualisation.memorySize = 1024;

        services.declarative-jellyfin = {
          enable = true;
          package = import ../../patched-jellyfin.nix pkgs;
          network = {
            publishedServerUriBySubnet = [
              "all=https://test.test.test"
            ];
            enableHttps = true;
            requireHttps = true;
            certificatePath = "/path/to/cert";
          };
        };
      };
    };

    testScript =
      # py
      ''
        import xml.etree.ElementTree as ET

        machine.wait_until_succeeds("test -e /var/lib/jellyfin/init-done", timeout=300)

        # Make sure every config can be parsed without erros
        ${pkgs.lib.concatStringsSep "\n" (
          pkgs.lib.mapAttrsToList (_name: path: "machine.succeed(\"xmlstarlet val '${path}'\")") configs
        )}


        with subtest("network.xml"):
          # stupid fucking hack because you cant open files in python for some reason
          xml = machine.succeed("cat '${configs.network}'")
          tree = ET.ElementTree(ET.fromstring(xml))
          if tree is None:
            raise TypeError
          root = tree.getroot()
          if root is None:
            raise TypeError

          with subtest("PublishedServerUriBySubnet"):
            for child in root:
              if child.tag == "PublishedServerUriBySubnet":
                try:
                  if child[0].text == "all=https://test.test.test":
                    break
                except:
                  print("An error occured when trying to parse xml")
                  print(xml)
                  assert False, "Exception occured, check output above"
            else:
              assert False, "The shit was not found. Full XML: " + xml

          with subtest("EnableHttps"):
            for child in root:
              if child.tag == "EnableHttps":
                if child.text == "true":
                  break
            else:
              assert False, "The shit was not found. Full XML: " + xml

          with subtest("RequireHttps"):
            for child in root:
              if child.tag == "RequireHttps":
                if child.text == "true":
                  break
            else:
              assert False, "The shit was not found. Full XML: " + xml
      '';
  };
}
