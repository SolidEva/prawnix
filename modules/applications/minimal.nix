# minimal, headless application set
# graphical applications should go in either graphical or graphical-full
{ pkgs, sources, self, user, lib, ... }:

{
  imports =
  [
    (self + /modules/applications/configs/helix.nix)
  ];

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # basic tools
    dtrx
    fd
    file
    fzf
    lon
    ncdu # tui for disk usage
    nix-diff
    nmap
    ripgrep
    rsync
    sbctl
    sops
    ssh-to-age # for sops-nix
    tcpdump
    tmux
    traceroute
    tree
    unzip
    wireguard-tools
    wget
    zenith # top/htop replacement

    # nix specific tools
    optnix # useful for local search of nixos options

    # image tools
    ghostscript
    imagemagick

    # hardware tools
    minicom
    pciutils
    usbmuxd

  ];

  programs.gnupg.agent = {
     enable = true;
     pinentryPackage = pkgs.pinentry-curses;
  };

  # setup some sane git options
  programs.git.enable = true;
  programs.git.lfs.enable = true;
  programs.git.config =  {
    init = {
      defaultBranch = "main";
    };
    color = {
      ui = true;
    };
    core = {
      editor = "hx";
      pager = "less";
    };
    pull = {
      rebase = true;
    };
    push = {
      autoSetupRemote = true;
    };
  };

  # enable iphone tethering for iphone users
  services.usbmuxd.enable = true;

  programs.direnv.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = "set -g mouse on";
  };
}
