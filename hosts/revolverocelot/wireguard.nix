{ self, sources, config, ... }:
let
  secrets = import "${sources.prawnix-secrets-revolverocelot}/default.nix";
  wireguard_peer_input_chain = "WIREGUARD-PEER-INPUT";
  ignore_result = " >/dev/null 2>/dev/null || true";
in
{

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.useNetworkd = true;

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enp1s0";
    internalInterfaces = [ "wg0" ];
  };

  services.resolved.settings.Resolve = {
    DNSStubListener=true;
    DNSStubListenerExtra=["192.168.26.1" "beef:beef:beef::1"];
  };


  # rather than open up port 53 for all interfaces, only open it for the wg interface
  networking.firewall.extraCommands = ''
  # IPV6 rules
  # allow dns lookups from wg0
  ip6tables  --new-chain ${wireguard_peer_input_chain};
  ip6tables  -A INPUT -j ${wireguard_peer_input_chain}
  ip6tables  -A ${wireguard_peer_input_chain} -i wg0 -p tcp --dport 53 -j ACCEPT
  ip6tables  -A ${wireguard_peer_input_chain} -i wg0 -p udp --dport 53 -j ACCEPT

  # IPV4 rules
  # allow dns lookups from wg0
  iptables  --new-chain ${wireguard_peer_input_chain};
  iptables  -A INPUT -j ${wireguard_peer_input_chain}
  iptables  -A ${wireguard_peer_input_chain} -i wg0 -p tcp --dport 53 -j ACCEPT
  iptables  -A ${wireguard_peer_input_chain} -i wg0 -p udp --dport 53 -j ACCEPT
  '';

  # clean up our chains, otherwise every rebuild just adds the rules again and again :p
  # have to use ${ignore_result} otherwise the rebuild will fail if these chains dont already exist
  networking.firewall.extraStopCommands = ''
  # Remove IPV4 chains
  iptables -D INPUT -j ${wireguard_peer_input_chain} ${ignore_result}
  iptables --flush ${wireguard_peer_input_chain} ${ignore_result}
  iptables --delete-chain ${wireguard_peer_input_chain} ${ignore_result}

  # Remove IPV6 chains
  ip6tables -D INPUT -j ${wireguard_peer_input_chain} ${ignore_result}
  ip6tables --flush ${wireguard_peer_input_chain} ${ignore_result}
  ip6tables --delete-chain ${wireguard_peer_input_chain} ${ignore_result}
  '';

  systemd.network = {
    enable = true;

    networks."50-wg0" = {
      matchConfig.Name = "wg0";

      address = [
        "beef:beef:beef::1/128"
        "192.168.26.1/32"
      ];
      networkConfig = {
        # do not use IPMasquerade,
        # allegedly: unnecessary, causes problems with host ipv6
        IPv4Forwarding = true;
        IPv6Forwarding = true;
      };
    };

    netdevs."50-wg0" = {
      netdevConfig = {
        Kind = "wireguard";
        Name = "wg0";
      };

      wireguardConfig = {
        ListenPort = 51820;
        # ensure file is readable by `systemd-network` user
        PrivateKeyFile = config.sops.secrets."wireguard/privatekey".path;
        RouteTable = "main";
      };
      wireguardPeers = [
        {
          PublicKey = secrets.wireguard_sunny_pub;
          AllowedIPs = [
            "beef:beef:beef::4/128"
            "192.168.26.4/32"
          ];
          PresharedKeyFile = config.sops.secrets."wireguard/presharedkey/sunny".path;
        }
        {
          PublicKey = secrets.wireguard_android_pub;
          AllowedIPs = [
            "beef:beef:beef::5/128"
            "192.168.26.5/32"
          ];
          PresharedKeyFile = config.sops.secrets."wireguard/presharedkey/android".path;
        }
      ];
    };
  };
}
