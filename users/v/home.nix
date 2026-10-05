{ pkgs, ... }:

{
  imports = [
    ../../modules/home/notify.nix
    ../../modules/home/claude-code.nix
    ../../modules/home/pi.nix
    ../../modules/home/tmux.nix
  ];

  home = {
    # First Home Manager release used for this home. Do not bump on updates.
    stateVersion = "26.05";

    packages = with pkgs; [
      git
      delta
      gnumake
      glow
      lazygit
      tree
    ];

    shellAliases = {
      gg = "lazygit";
      t = "tmux";
    };
    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.bash = {
    enable = true;
    # Keep NixOS's existing Bash package, completion, and history/shopt defaults.
    package = null;
    enableCompletion = false;
    historySize = null;
    historyFileSize = null;
    shellOptions = [ ];
  };
}
