{ self, pkgs, ... }:

let
  host_niri_conf = (
    pkgs.writeTextFile {
      name = "host_niri_conf";
      text = ''

        // import base config
        include "./baseconfig.kdl"


        // add addiitonal config or override base options below
        // You can configure outputs by their name, which you can find
        // by running `niri msg outputs` while inside a niri instance.
        // The built-in laptop monitor is usually called "eDP-1".
        // Find more information on the wiki:
        // https://niri-wm.github.io/niri/Configuration:-Outputs
        // Remember to uncomment the node by removing "/-"!
        output "Samsung Electric Company Odyssey G95NC HNTY800969" {
            // Uncomment this line to disable this output.
            // off

            // Resolution and, optionally, refresh rate of the output.
            // The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
            // If the refresh rate is omitted, niri will pick the highest refresh rate
            // for the resolution.
            // If the mode is omitted altogether or is invalid, niri will pick one automatically.
            // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
            mode "7680x2160@59.987"

            // You can use integer or fractional scale, for example use 1.5 for 150% scale.
            scale 1.2

            // Transform allows to rotate the output counter-clockwise, valid values are:
            // normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
            transform "normal"

            // Position of the output in the global coordinate space.
            // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
            // The cursor can only move between directly adjacent outputs.
            // Output scale and rotation has to be taken into account for positioning:
            // outputs are sized in logical, or scaled, pixels.
            // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
            // so to put another output directly adjacent to it on the right, set its x to 1920.
            // If the position is unset or results in an overlap, the output is instead placed
            // automatically.
            position x=0 y=0
        }

        // set our wallpaper
        spawn-at-startup "swaybg" "-i" "/etc/wallpapers/horizontal/mtn_town.jpg" "-m" "fill"

        layout {
            // You can change the default width of the new windows.
            default-column-width { proportion 0.25; }
        }
      '';
    }
  );

in

{
  imports = [
    ./default.nix
    (self + /modules/wallpapers/default.nix)
  ];

  # install this hosts niri config
  # it should reference the default config
  environment.etc = {
    "niri/config.kdl".source = host_niri_conf;
  };

  # install the default config
  environment.etc = {
    "niri/baseconfig.kdl".source = ./baseconfig.kdl;
  };

}
