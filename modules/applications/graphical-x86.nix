# general applications
{ pkgs, user, ... }:

{
  imports =
  [
    ./configs/qemu.nix
  ];


# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    discord
    spotify
    tor-browser
    steam-run
  ];

  programs.steam.enable = false;

  # enable thunderbolt configuration
  # thunderbolt devices still likely need to be enrolled depending on your setting here
  # cat /sys/bus/thunderbolt/devices/domain0/security
  # https://nixos.wiki/wiki/Thunderbolt
  # https://wiki.archlinux.org/title/Thunderbolt
  services.hardware.bolt.enable = true;

}
