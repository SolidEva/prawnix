# general graphical applications, shared between DEs/WMs
# this should be kept minimal, most packages should go in graphical-full.nix
{ pkgs, self, ... }:

{
  imports =
  [
    ./minimal-dev.nix
    (self + /modules/applications/configs/keepmenu.nix)
  ];

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Set Firefox as the default browser
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
  environment.sessionVariables.DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    calibre
    gimp
    handbrake
    keepassxc
    libreoffice-qt
    mpv
    vlc

    #filesystem management
    gparted
    exfatprogs
    ntfs3g
  ];

}
