# Declarative Jellyfin

![workflows badge](https://git.spoodythe.one/spoody/declarative-jellyfin/badges/workflows/run-tests.yml/badge.svg?branch=main)
![issues badge](https://git.spoodythe.one/spoody/declarative-jellyfin/badges/issues.svg)

> [!NOTE]
Consider using [Jellar](https://github.com/venkyr77/jellarr) instead, as it solves some of the 
fundamental problems this project have. You can read more about why in Jellar's README.

This repository provides a Nix flake that allows for declarative configuration of
Users, Libraries, Settings, etc.

# Features
* Declarative users
    * permissions
* Libraries
    * User specific library access
* Server Settings
    * System
    * Network
    * Encoding (HW acceleration)
    * Branding settings
* Automatic backups
* API keys

# Documentation
Automatically generated documentation outlining all options is available in [documentation.md](https://github.com/Sveske-Juice/declarative-jellyfin/blob/main/documentation/documentation.md)

# FAQ
Frequently asked questions and common problems are documented in [FAQ.md](https://github.com/Sveske-Juice/declarative-jellyfin/blob/main/FAQ.md)

# Usage
## Setup
Add the flake to your `inputs` and import the `nixosModule` in your configuration.

Example minimal flake.nix:
```nix
{
  description = "An example using declarative-jellyfin flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    declarative-jellyfin.url = "github:Sveske-Juice/declarative-jellyfin";
  };

  outputs = {
    nixpkgs,
    declarative-jellyfin,
    ...
  }: {
    nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
      modules = [
        declarative-jellyfin.nixosModules.default # <- this imports the NixOS module that provides the options
        ./configuration.nix # <- your host entrypoint
      ];
    };
  };
}
```
## Examples
See the [example](https://github.com/Sveske-Juice/declarative-jellyfin/tree/main/examples) directory for example configs.

## General server settings
You can configure system settings through the `services.declarative-jellyfin.system` options.

Example:

```nix
services.declarative-jellyfin.system = {
  serverName = "My Declarative Jellyfin Server";
  # Use Hardware Acceleration for trickplay image generation
  trickplayOptions = {
    enableHwAcceleration = true;
    enableHwEncoding = true;
  };
  UICulture = "da"; # Make the UI language danish
};
```

## Users
You can configure users with the options provided by `services.declarative-jellyfin.users`.

Example:

```nix
services.declarative-jellyfin.users = {
  admin = {
    mutable = false; # overwrite user settings
    permissions.isAdministrator = true;
    hashedPasswordFile = config.sops.secrets.jellyfin-admin-passwd.path;
  };
  "Alice Doe" = {
    password = "123"; # WARNING: plain text!
    permissions.enableMediaPlayback = false; # this user is not allowed to play media
  };
};
```

> [!NOTE]
When `users.<name>.mutable = true` (default), the settings configured in your nix configuration will only be applied
once when the user is first generated. You can therefore use the GUI to configure the user if you please. When
`users.<name>.mutable = false` every user setting will be overwritten when jellyfin starts. This can be usefull if
you want a user to be fully declarative (for example admin accounts).

### Generate user password hash
Jellyfin uses pbkdf2-sha512 hashes to store passwords.
Use the `genhash` script bundled in this flake with the parameters the jellyfin DB expects:
```sh
$ nix run github:Sveske-Juice/declarative-jellyfin#genhash -- -i 210000 -l 128 -u -k "your super secret password"
```

### Usage with sops-nix
Extract the secret and use the `hashedPasswordFile`:
```nix
sops.secrets.example-user-password = {
    owner = config.services.jellyfin.user;
    group = config.services.jellyfin.group;
};
services.declarative-jellyfin.users.example-user.hashedPasswordFile = config.sops.secrets.example-user-password.path;
```

## Libraries
You can configure libraries with the options provided by `services.declarative-jellyfin.libraries`.

Below are some examples of different types of libraries:

<details>
    <summary>Movies</summary>

```nix
services.declarative-jellyfin.libraries.Movies = {
  enabled = true;
  contentType = "movies";
  pathInfos = ["/data/Movies"];
};
```
</details>

<details>
    <summary>TV Shows</summary>

```nix
services.declarative-jellyfin.libraries.Shows = {
  enabled = true;
  contentType = "tvshows";
  pathInfos = ["/data/Shows"];
};
```
</details>

<details>
    <summary>Home Videos and Photos</summary>

```nix
services.declarative-jellyfin.libraries."Family photos" = {
  enabled = true;
  contentType = "homevideos";
  pathInfos = ["/data/Famility/Photos" "/data/Family/Videos"];
};
```
</details>

<details>
    <summary>Books</summary>

```nix
services.declarative-jellyfin.libraries.Books = {
  enabled = true;
  contentType = "books";
  pathInfos = ["/data/Books"];
};
```
</details>

<details>
    <summary>Music</summary>

```nix
services.declarative-jellyfin.libraries.Music = {
  enabled = true;
  contentType = "music";
  pathInfos = ["/data/Music"];
};
```
</details>

See the [source code](https://github.com/jellyfin/jellyfin/blob/master/MediaBrowser.Model/Entities/CollectionTypeOptions.cs)
for possible library content types.

> [!NOTE]
By declaring libraries through your nixos configuration, any changes through the GUI will be overwritten by restarting jellyfin.
If you want to change settings through the GUI, you must not specify the library in your configuration, otherwise you've to specify the options in the config.

### Limit a user's access to specific libraries
To whitelist the libraries the user have access to, you can use `services.declarative-jellyfin.users.<name>.preferences.enabledLibraries`:

```nix
services.declarative-jellyfin.users.your-username = {
  # ...
  preferences = {
    enabledLibraries = ["Movies" "Photos and Videos"]; # Libraries that the user has access to
  };
  permissions = {
    enableAllFolders = false;
  };
};
```
It's important to disable `permissions.enableAllFolders` otherwise the preferences won't have any effect.

## Hardware Acceleration
First figure out what HW acceleration methods your system supports: https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration/

Then configure the options through `services.declarative-jellyfin.encoding`.

### Example with AMD VA-API:
```nix
# AMD VA-API and VDPAU should work out of the box with mesa
hardware.graphics.enable = true;
users.users.${config.services.jellyfin.user}.extraGroups = ["video" "render"];

services.declarative-jellyfin = {
    # ... other configuration ...
    encoding = {
      enableHardwareEncoding = true;
      hardwareAccelerationType = "vaapi";
      enableDecodingColorDepth10Hevc = true; # enable if your system supports
      allowHevcEncoding = true; # enable if your system supports
      allowAv1Encoding = true; # enable if your system supports
      hardwareDecodingCodecs = [ # enable the codecs your system supports
        "h264"
        "hevc"
        "mpeg2video"
        "vc1"
        "vp9"
        "av1"
      ];
    };
};
```
Use `vainfo` from `libva-utils` to see the codec capabilities for your VA-API device.

## Plugins

> [!CAUTION]
At the moment only plugin repositories can be configured with this flake. For now you have 
to imperatively install and configure plugins.

Plugins are very difficult to manage declaratively, so for now you can only manage the plugin repositories declaratively

```nix
services.declarative-jellyfin = {
    system.pluginRepositories = [
        {
          content = {
            Name = "Jellyfin Stable";
            Url = "https://repo.jellyfin.org/files/plugin/manifest.json";
          };
          tag = "RepositoryInfo"; # Needed to generate the correct XML
        }

        {
          content = {
            Name = "Intro Skipper";
            Url = "https://intro-skipper.org/manifest.json";
          };
          tag = "RepositoryInfo"; # Needed to generate the correct XML
        }
    ];
};
```

This will download the specified verson of the plugin and install it for you during evaluation.

### Configuring plugins

This is still not possible, but is being worked on.

## Migrating from existing config

Declarative Jellyfin is designed to be a drop-in replacement for the normal jellyfin service.

```diff
- services.jellyfin = {
+ services.declarative-jellyfin = {
```

## API Keys
> [!WARNING]
Always use `keyPath` together with a secret manager, instead of storing api keys in plaintext with `key`.

Example:
```nix
services.declarative-jellyfin.apikeys = {
  Jellyseerr = {
    keyPath = config.sops.secrets.my-jellyfin-jellyseerr-key.path;
  };
  "Homarr Dashboard" = {
    key = "78878bf9fc654ff78ae332c63de5aeb6"; # WARNING: plain-text!
  };
};
```

# Known Issues

## Intro Skipper stops working after a while

Don't know why this happens. A workaround is to restart jellyfin (through the dashboard, restarting the service doesn't count) which will make it work again for a while.
