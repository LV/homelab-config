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
    # The default 127.0.0.1:8384 stays; exposed only through tailscale serve
    guiPasswordFile = "/run/credentials/syncthing-init.service/gui-password";
    settings = {
      options.urAccepted = -1;
      gui = {
        user = "v";
        # Serve forwards the tailnet Host header, which the localhost
        # bind would otherwise reject
        insecureSkipHostcheck = true;
      };
    };
  };

  homelab.tailscaleServe.syncthing = 8384;

  systemd.services = {
    # syncthing-init hashes the password and sets it through the REST API.
    # The password is chosen by hand; see docs/naming-schema.md
    syncthing-init.serviceConfig.LoadCredential = [
      "gui-password:/var/lib/secrets/syncthing-gui-password"
    ];
    # Never expose the GUI before its password is set
    tailscale-serve-syncthing = {
      requires = [ "syncthing-init.service" ];
      after = [ "syncthing-init.service" ];
    };
  };
}
