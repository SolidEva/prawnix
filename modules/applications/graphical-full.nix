# general applications
{ pkgs, user, ... }:

{
  imports =
  [
    # smaller configs
    ./minimal-dev.nix
    ./graphical.nix

    # application specific configs
    # these might be desirable in a smaller config
    # and require more than just a one line change to include
    ./configs/qemu.nix
    ./configs/syncthing.nix
  ];


# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # extra apps
    android-tools
    anki
    arp-scan
    borgbackup
    chromium
    cinny-desktop
    deezer-desktop
    devcontainer # used for zmk build
    discord
    drawio
    element-desktop
    easyeffects # improve sound
    ffmpeg
    freecad-wayland
    ghidra # reverse engineering tools
    kicad
    krita
    mediainfo
    mumble
    nvme-cli
    openscad
    pdftk
    pdfchain
    qFlipper
    sabnzbd
    signal-desktop
    smartmontools
    spotify
    steam-run
    telegram-desktop
    thunderbird
    tlp # power monitoring
    transmission_4-gtk
    vorta
    wireshark
    yt-dlp
  ];

  programs.steam.enable = true;

  users.users.${user}.extraGroups = ["adbusers" "kvm"]; # for android dev

  # enable thunderbolt configuration
  # thunderbolt devices still likely need to be enrolled depending on your setting here
  # cat /sys/bus/thunderbolt/devices/domain0/security
  # https://nixos.wiki/wiki/Thunderbolt
  # https://wiki.archlinux.org/title/Thunderbolt
  services.hardware.bolt.enable = true;

  # required for element desktop
  services.gnome.gnome-keyring.enable = true;
}
