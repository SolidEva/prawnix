{ sources, config, ... }:
let
  secrets = import "${sources.prawnix-secrets-rex}/default.nix";
in
{
  imports = [
    "${sources.sops-nix}/modules/sops"
  ];

  sops = {
    defaultSopsFile = secrets.secretsFile;

    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "graphenix/tokay/password" = {
        owner = "root";
        group = config.services.graphenix.group;
        mode = "0640";
      };
      "graphenix/caiman/password" = {
        owner = "root";
        group = config.services.graphenix.group;
        mode = "0640";
      };
    };
  };
 }
