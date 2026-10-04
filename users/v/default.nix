_:

{
  uid = 1000;
  extraGroups = [
    "wheel"
    "media"
  ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGsWJgncIoAVKioYVVMfqn7g0mSnpLORTgZg3UNNDxJ" # laptop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKphnA9IH9KO8cKi7ZzX+zZzb74aU7UrVliw8vq4id6w" # phone
  ];
}
