_:

{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 1000000;
    keyMode = "vi";
    escapeTime = 10; # Keep Esc responsive.
    baseIndex = 1;
    focusEvents = true;
    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      set -g set-clipboard on
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -g mouse on
      set -g renumber-windows on
      set -g set-titles on
      set -g set-titles-string '#T'
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
