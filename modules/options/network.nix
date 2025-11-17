{lib, ...}:
with lib; {
  options.services.declarative-jellyfin.network = {
    baseUrl = mkOption {
      type = types.str;
      default = "";
      description = "Add a custom subdirectory to the server URL. For example: http://example.com/<baseurl>";
    };
    enableHttps = mkEnableOption "Enable HTTPS";
    requireHttps = mkEnableOption "Require HTTPS";
    certificatePath = mkOption {
      type = with types; either str path;
      default = "";
      description = "Path to a PKCS #12 file containing a certificate and private key to enable TLS support on a custom domain.";
    };
    certificatePassword = mkOption {
      type = types.str;
      default = "";
      description = "If your certificate requires a password, please enter it here.";
    };
    internalHttpPort = mkOption {
      type = types.port;
      default = 8096;
      description = "The TCP port number for the HTTP server.";
    };
    internalHttpsPort = mkOption {
      type = types.port;
      default = 8920;
      description = "The TCP port number for the HTTPS server.";
    };
    publicHttpPort = mkOption {
      type = types.port;
      default = 8096;
      description = "The public port number that should be mapped to the local HTTP port.";
    };
    publicHttpsPort = mkOption {
      type = types.port;
      default = 8920;
      description = "The public port number that should be mapped to the local HTTPS port.";
    };
    autoDiscovery = mkOption {
      type = types.bool;
      default = true;
      description = "Enable auto discovery";
    };
    enableUPnP = mkEnableOption "Enable UPnP forwarding";
    enableIPv4 = mkOption {
      type = types.bool;
      default = true;
      description = "Enable IPv4 routing";
    };
    enableIPv6 = mkOption {
      type = types.bool;
      default = false;
      description = "Enable IPv6 routing";
    };
    enableRemoteAccess = mkOption {
      type = types.bool;
      default = true;
      description = "Enable remote access";
    };
    localNetworkSubnets = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        List of IP addresses or IP/netmask entries for networks that will be considered on local network when enforcing bandwidth restrictions.
        If set, all other IP addresses will be considered to be on the external network and will be subject to the external bandwidth restrictions.
        If left empty, only the server's subnet is considered to be on the local network.
      '';
    };
    localNetworkAddresses = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        List of interface addresses which Jellyfin will bind to. If empty, all interfaces will be used.
      '';
    };
    knownProxies = mkOption {
      type = with types; listOf str;
      description = "A list of known proxies";
      default = [];
    };
    ignoreVirtualInterfaces = mkOption {
      type = types.bool;
      default = true;
      description = "Ignore virtual interfaces";
    };
    virtualInterfaceNames = mkOption {
      type = with types; listOf str;
      description = "List of virtual interface names";
      default = ["veth"];
    };
    enablePublishedServerUriByRequest = mkEnableOption "Enable published server uri by request";
    publishedServerUriBySubnet = mkOption {
      type = with types; listOf str;
      description = ''
        Override the URI used by Jellyfin, based on the interface, or client IP address.

        For example: `["internal=http://jellyfin.example.com" "external=https://jellyfin.example.com"]` or `["all=https://jellyfin.example.com"]`
      '';
      default = [];
    };
    remoteIpFilter = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        List of IP addresses or IP/netmask entries for networks that will be allowed to connect remotely.
        If left empty, all remote addresses will be allowed.
      '';
    };
    isRemoteIPFilterBlacklist = mkEnableOption "Is the remote ip filter list a blacklist or a whitelist";
  };
}
