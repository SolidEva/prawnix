# base configuration for all platforms, used by all hosts

{ user, pkgs, self, ... }:

{
  imports =
    [
      ./tack.nix
      (self + /modules/fish/fish.nix)
    ];

  # use lix
  nix.package = pkgs.lixPackageSets.stable.lix;

  # never allow flake configs by default
  nix.settings.accept-flake-config = false;

  # Enable networking
  networking.networkmanager.enable = true;

  # enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # trust all users in the wheel group, aka the sudoers
  nix.settings.trusted-users = [ "@wheel" ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "de_se_fi"; # add umlauts/sharp s by pressing right alt (alt gr)
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # enable the firmware update service
  services.fwupd.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "${user}";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # garbage collect
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 5d";
  };

  # rebuild script
  environment.systemPackages = [
    (pkgs.writeShellApplication {
          name = "nixos";

          text = ''
            set -euo pipefail

            # assumes the user keeps prawnix at the root of their home dir
            nixos-rebuild --no-flake --sudo --file /home/${user}/prawnix/default.nix -A "nixosConfigurations.$(hostname)" "$@"

          '';
    })
  ];
}
