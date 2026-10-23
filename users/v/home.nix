{ pkgs, ... }:

{
  imports = [
    ../../modules/home/notify.nix
    ../../modules/home/claude-code.nix
    ../../modules/home/codex.nix
    ../../modules/home/pi.nix
    ../../modules/home/tmux.nix
    ../../modules/home/neovim.nix
  ];

  home = {
    # First Home Manager release used for this home. Do not bump on updates.
    stateVersion = "26.05";

    packages = with pkgs; [
      git
      delta
      gnumake
      glow
      go
      lazygit
      nodejs
      python3
      tree
      uv
    ];

    shellAliases = {
      gg = "lazygit";
      t = "tmux";
      v = "nvim";
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
    initExtra = ''
      mkcdir () {
          mkdir -p -- "$1" &&
             cd -P -- "$1"
      }
    '';
  };

  programs.gh.enable = true;
}
