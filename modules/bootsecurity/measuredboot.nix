{ sources, pkgs, lib, ... }:
let

  lanzaboote = import sources.lanzaboote {
    inherit pkgs;
  };
in

{
  imports = [ lanzaboote.nixosModules.lanzaboote ];


  boot.initrd.systemd.enable = true;
  boot.lanzaboote = {
    measuredBoot = {
      enable = true;
      pcrs = [
        0
        4
        7
      ];
    };
  };
}
