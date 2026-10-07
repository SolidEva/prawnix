{
  pkgs,
  config,
  user,
  self,
  ...
}:

let
  nmtuiLauncher = pkgs.writeShellScriptBin "nmtuiLauncher" ''
    sleep 0.6 # fixes nmtui displaying incorrectly
    ${pkgs.networkmanager}/bin/nmtui
  '';
in
{
  imports = [
    (self + "/modules/mako/default.nix") # for notifications
    (self + "/modules/waybar/default.nix")
    (self + "/modules/fuzzel/default.nix")
  ];

  programs.niri.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${config.programs.niri.package}/bin/niri-session";
        inherit user;
      };
    };
  };

  # TODO is this required??
  # NixOS otherwise injects a stripped PATH via Environment= on the niri.service
  # unit which shadows the imported user-manager PATH. Disabling the default
  # lets niri inherit the full PATH set up by niri-session.
  # systemd.user.services.niri.enableDefaultPath = false;

  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  security.pam.services.swaylock = { };

  services.xserver.updateDbusEnvironment = true;

  environment.systemPackages = with pkgs; [
    alacritty
    brightnessctl
    swaybg
    swaylock
    swayidle
    xwayland-satellite

    wl-clipboard # lets manage the system clipboard from the cli
    wl-gammactl
    wf-recorder
    nautilus # gui file explorer
    eog # image viewer
    gcolor3 # color picker
    grim
    jq
    kanshi
    papers # pdf viewer
    slurp
    tofi # menu/launcher
    blueman # bluetooth settings
    pavucontrol # sound settings
    alsa-tools # aplay, hda-verb, etc
    lshw
    udiskie
    wlogout # shutdown/reboot/logout window
    nwg-displays

    ## Utility Scripts

    # simple script which prompts the user to select a region to screenshot, and puts the image on the clipboard
    (pkgs.writeShellScriptBin "screenshot-script" ''
      ${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - - | ${pkgs.wl-clipboard}/bin/wl-copy
    '')

    ## Desktop files

    ### Settings shortcuts
    (pkgs.makeDesktopItem {
      name = "network-settings";
      desktopName = "Network Settings";
      exec = "/run/current-system/sw/bin/alacritty --command ${nmtuiLauncher}";
      keywords = [
        "wifi"
        "network"
        "networks"
        "ethernet"
        "settings"
      ];
    })
    (pkgs.makeDesktopItem {
      name = "sound-settings";
      desktopName = "Sound Settings";
      exec = "/run/current-system/sw/bin/pavucontrol";
      keywords = [
        "sound"
        "audio"
        "settings"
      ];
    })

    ### system state shortcuts
    (pkgs.makeDesktopItem {
      name = "shutdown-reboot-logout-lock-shortcut";
      desktopName = "Shutdown/Reboot/Logout/Lock";
      exec = "/run/current-system/sw/bin/wlogout";
      keywords = [
        "shutdown"
        "power"
        "reboot"
        "logout"
        "lock"
      ];
    })

    ### Utility Shotcuts
    (pkgs.makeDesktopItem {
      name = "screenshot-clipboard";
      desktopName = "Screenshot to Clipboard";
      exec = "/run/current-system/sw/bin/screenshot-script";
      keywords = [ "screenshot" ];
    })
  ];


  fonts.packages = with pkgs; [
    cantarell-fonts
    dejavu_fonts
    source-code-pro
    source-sans
    font-awesome
    powerline-fonts
    powerline-symbols

    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # setup default applications
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "image/jpeg" = "org.gnome.eog.desktop";
    "image/png" = "org.gnome.eog.desktop";
    "image/svg" = "org.gnome.eog.desktop";
  };

  xdg.mime.defaultApplications = {
    "application/pdf" = "org.gnome.Papers.desktop";
  };

}
