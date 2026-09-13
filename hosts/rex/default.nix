# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, self, lib, pkgs, sources, user, ... }:
let

  hostname = "rex";
  # must be one of the .nix files in modules/platform
  platform = "server";
  primary-eth="enp11s0";

  secrets = import "${sources.prawnix-secrets-rex}/default.nix";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # platform specific configuration
      (self + /modules/platform/${platform}.nix)
      # application suite
      (self + /modules/applications/minimal-dev.nix)
    ];

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  networking.hostName = "${hostname}"; # Define your hostname.

  networking.networkmanager.enable = true;

  services.openssh = {
    settings.PermitRootLogin = "no";
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."arthur" = {
    isNormalUser = true;
    description = "arthur";
    extraGroups = config.users.users.${user}.extraGroups;
  };

  networking = {
    useDHCP = lib.mkDefault true;
    interfaces.${primary-eth} = {
        macAddress = "d8:43:ae:a6:4f:d0";
        useDHCP = lib.mkDefault true;
      };
  };


# remote unlock
  boot.initrd = {
    # Enable systemd in the initial ramdisk environment
    systemd = {
      enable = true;
      # Configure networking using systemd's network manager

      # if you don't need to override any of the
      # normal running systems network interface configuration
      # you can remove this section
      network = {
        enable = true;
        # mkForce is required to override the normal systems
        # MAC and hostname
        networks =  lib.mkForce {
          "${primary-eth}" =  {
            matchConfig = {
              Name = "${primary-eth}";  # Matches the network interface by name
            };
            networkConfig = {
              DHCP = "yes";  # Enable DHCP
            };
            # set a different mac address for the initrd so the router
            # can assign a different static ip for the initrd
            # this ensures that any open ports on the router, which
            # route to the server during normal operation, are not
            # routed to the servers initrd
            linkConfig = {
              MACAddress =  "d8:43:ae:a6:09:f9";
            };
            # set a different hostname for the initrd to differentiate
            # it from the normal-running system
            dhcpV4Config = {
              Hostname =  "${hostname}-decrypt";
            };
            dhcpV6Config = {
              Hostname = "${hostname}-decrypt";
            };
          };
        };
      };
    };

    # Configure SSH access during early boot
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;  # Use a non-standard port for security
        # Only allow running the unlock service when connecting via SSH
        authorizedKeys = [
          ''command="systemctl default" ${secrets.initrd.authorized_key.primary}''
          ''command="systemctl default" ${secrets.initrd.authorized_key.secondary}''
          ''command="systemctl default" ${secrets.initrd.authorized_key.arthur}''
        ];
        # Location of the SSH host key
        # TODO document creating a key here as part of setup
        # sudo ssh-keygen -t ed25519 -f /etc/ssh/initrd_ssh_host_ed25519_key -C "eva@host"
        hostKeys = [ secrets.initrd.host_key ];
      };
    };
  };


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
