_:

{
  services.syncthing = {
    enable = true;
    user = "v";
    dataDir = "/home/v";
    configDir = "/home/v/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
    settings.options.urAccepted = -1;
  };
}
