{ inputs, pkgs, ... }:

{
  # Every script in the dotfiles' bin/, so new ones arrive with `make update`.
  # bin/dotfiles links profiles, which NixOS hosts don't use.
  home.packages = [
    (pkgs.runCommand "dotfiles-bin" { } ''
      mkdir -p $out/bin
      ln -s ${inputs.dotfiles}/bin/* $out/bin/
      rm $out/bin/dotfiles
    '')
  ];

  # Prompt, aliases, and functions; Home Manager still owns ~/.bashrc itself.
  programs.bash.initExtra = "source ${inputs.dotfiles}/config/bash/.bashrc";

  xdg.configFile."bat/config".source = inputs.dotfiles + "/config/bat/config";
}
