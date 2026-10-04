# Users

Each immediate directory under `users/` creates a normal NixOS account and a
Home Manager configuration. The directory name supplies the username; NixOS
supplies its home directory. Service accounts remain in system service modules.

## Add a user

1. Create `users/<name>/` with both files below.
2. Set that user's SSH keys and groups in `default.nix`. Do not copy `v`'s keys,
   UID, or administrative groups. Without SSH keys, key-only SSH is unavailable.
3. Add the new files to Git so the flake sees them, then run `make lint` and
   build before applying with `make switch`.

`default.nix` — account options (normal-user defaults come from the loader):

```nix
_:
{
  openssh.authorizedKeys.keys = [ "ssh-ed25519 REPLACE_WITH_PUBLIC_KEY" ];
}
```

`home.nix` — personal packages and settings:

```nix
{ pkgs, ... }:
{
  home.stateVersion = "26.05"; # Keep the initial version on future upgrades.
  home.packages = [ pkgs.git ];
  programs.bash.enable = true;
}
```

## Boundaries

- Account identity, SSH keys, and groups: `users/<name>/default.nix`.
- Personal packages, shell settings, and home files: `users/<name>/home.nix`.
- Reusable personal tools: `modules/home/`, imported explicitly by each user.
- System services, networking, privileged helpers, and shared directories:
  NixOS. Syncthing remains its existing system service owned by `v`.

`make switch` applies NixOS and Home Manager together. Home Manager refuses to
overwrite conflicting existing dotfiles: back them up before activation rather
than enabling forced replacement. Log in again to pick up session changes.

Deleting a user directory removes its declarations; it is not a substitute for
backing up data or deliberately offboarding the account.
