{ pkgs, ... }:

let
  plannotator = pkgs.writeShellScriptBin "plannotator" ''
    exec "$HOME/.local/bin/plannotator" "$@"
  '';

  # Plannotator calls this with the session URL instead of opening a browser.
  # Rewrites it to this machine's tailnet name, shows it in tmux, and pushes
  # it via ntfy.
  plannotatorOpen = pkgs.writeShellApplication {
    name = "plannotator-open";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.tailscale
      pkgs.tmux
    ];
    text = ''
      url="$1"
      rest="''${url#*://}"
      hostport="''${rest%%/*}"
      path="''${rest#"$hostport"}"
      port="''${hostport##*:}"

      host="$(tailscale status --json | jq -r '.Self.DNSName | rtrimstr(".")')"
      link="http://$host:$port$path"

      # Show the link in the tmux status bar until a key is pressed,
      # and copy it to the tmux buffer and (via OSC 52) the client clipboard.
      if [ -n "''${TMUX:-}" ]; then
        tmux set-buffer -w "$link"
        tmux display-message -d 0 "Plannotator ready: $link"
      fi

      curl -fsS \
        -H "Authorization: Bearer $(< "$HOME/.config/ntfy/token")" \
        -H "Title: Plannotator" \
        -H "Click: $link" \
        -d "Review ready: $link" \
        https://ntfy.luis.vi/homelab > /dev/null || true
    '';
  };
in
{
  environment.systemPackages = [
    plannotator
    plannotatorOpen
  ];
}
