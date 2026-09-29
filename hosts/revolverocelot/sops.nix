{ sources,  ... }:
let
  secrets = import "${sources.prawnix-secrets-revolverocelot}/default.nix";
in
{
  imports = [
    "${sources.sops-nix}/modules/sops"
  ];

  sops = {
    defaultSopsFile = secrets.secretsFile;

    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "mailserver/account/eva/password" = {
        owner = "root";
        mode = "0600";
      };
      "wireguard/privatekey" = {
        owner = "systemd-network";
        group = "systemd-network";
        mode = "0640";
      };
      "wireguard/presharedkey/sunny" = {
        owner = "systemd-network";
        group = "systemd-network";
        mode = "0640";
      };
      "wireguard/presharedkey/android" = {
        owner = "systemd-network";
        group = "systemd-network";
        mode = "0640";
      };
    };
  };
 }
