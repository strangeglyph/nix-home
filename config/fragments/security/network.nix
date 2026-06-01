{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption mkIf types;
in
{
  options.glyph = {
    security.dnssec.enable = mkOption {
      description = "Enable DNSSEC and DNS+TLS (may cause issues on some wifis)";
      default = true;
      type = types.bool;
    };
  };

  config = {
    boot.kernel.sysctl = {
      # disable selective ack
      "net.ipv4.tcp_dsack" = "0";
      "net.ipv4.tcp_fack" = "0";
      "net.ipv4.tcp_sack" = "0";
      # protect against syn floods
      "net.ipv4.tcp_syncookies" = "1";

      # protect against source address spoofing
      "net.ipv4.conf.all.accept_source_route" = "0";
      "net.ipv4.conf.default.accept_source_route" = "0";
      "net.ipv6.conf.all.accept_source_route" = "0";
      "net.ipv6.conf.default.accept_source_route" = "0";
      "net.ipv4.conf.all.rp_filter" = "1";
      "net.ipv4.conf.default.rp_filter" = "1";

      "net.ipv4.tcp_rfc1337" = "1";

      # matches nixos defaults and sysctl can't merge equal values
      #"net.ipv6.conf.default.use_tempaddr" = "2";
      "net.ipv6.conf.all.use_tempaddr" = "2";
    };

    networking.networkmanager.connectionConfig."ipv6.ip6-privacy" = 2;
    systemd.network.config.networkConfig.IPv6PrivacyExtensions = "kernel";

    networking.firewall.enable = true;
    networking.nftables.enable = true;

    services.resolved.settings = mkIf config.glyph.security.dnssec.enable {
      Resolve.DNSSEC = "true";
      Resolve.DNSOverTLS = "opportunistic";
    };
  };
}
