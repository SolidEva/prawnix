# syncthing configuration
# runs as the current user
{  user, ... }:

{
  imports =
  [

  ];

# configure syncthing
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    # run as user
    user = user;
    group = "users";
    # lets use the usual syncthing config rather than confiuring syncthing
    # with nix
    dataDir = "/home/${user}";  # default location for new folders
    configDir = "/home/${user}/.config/syncthing";
    # Dont delete devices and folders that are created
    # by the web interface
    overrideDevices = false;
    overrideFolders = false;
  };


}
