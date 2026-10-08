{ sources, pkgs, lib, ... }:

let
  wrappers = import sources.wrappers { };

  macbat = pkgs.writeShellScript "macbat" ''
    capacity=$(<"/sys/class/power_supply/macsmc-battery/capacity")
    if [ "$(<"/sys/class/power_supply/macsmc-battery/status")" = "Charging" ]; then
       echo "{\"text\":\"$capacity% \",\"class\":\"charging\"}"
    else
       echo "{\"text\":\"$capacity% \"}"
    fi
  '';
in
{

  wrappers.waybar = {
    settings = {
      "custom/battery" = {
        exec = macbat;
        interval = 30;
        tooltip = false;
        return-type = "json";
      };
      battery = lib.mkForce {};
      modules-right = lib.mkForce [
        "pulseaudio"
        "network"
        "custom/battery"
        "clock"
      ];
    };
    "style.css".content = lib.mkForce ''

      * {
          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: "iosevka nerd font";
          font-weight: 500;
          font-size: 14px;
          padding: 0;
      }

      window#waybar {
          background: #574464;
          border: 2px solid #f1c4e0;
      }

      tooltip {
          background-color: #574464;
          border: 2px solid #F18FB0;
      }

      #clock,
      #tray,
      #custom-battery,
      #network,
      #pulseaudio {
          margin: 6px 6px 6px 0px;
          padding: 2px 8px;
      }

      #workspaces {
          background-color: #E9729D;
          margin: 6px 0px 6px 6px;
          /*border: 2px solid #434a4c;*/
      }

      #workspaces button {
          all: initial;
          min-width: 0;
          box-shadow: inset 0 -3px transparent;
          padding: 2px 4px;
          color: #140a1d;
      }

      #workspaces button.focused {
          color: #f1c4e0;
      }

      #workspaces button.urgent {
          background-color: #e78a4e;
      }

      #clock {
          background-color: #E9729D;
          /*border: 2px solid #434a4c;*/
          color: #140a1d;
      }


      #network,
      #pulseaudio {
          background-color: #bd93f9;
          /*border: 2px solid #F18FB0;*/
          color: #f1c4e0;
      }

      #custom-battery {
          background-color: #bd93f9;
          /*border: 2px solid #F18FB0;*/
          color: #f1c4e0;
      }
    '';
  };

}
