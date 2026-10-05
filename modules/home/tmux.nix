_:

{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 1000000;
    keyMode = "vi";
    escapeTime = 10; # Keep Esc responsive.
    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      set -g set-clipboard on
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -g mouse on
      set -g renumber-windows on
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
