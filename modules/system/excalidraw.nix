_:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.excalidraw = {
      image = "docker.io/excalidraw/excalidraw@sha256:f7ee194addd607bf831d2af0f0a34463dd4225e426cf35199ef0b12a803398e9";
      ports = [ "127.0.0.1:8085:80" ];
    };
  };

  homelab.tailscaleServe.excalidraw = 8085;
}
