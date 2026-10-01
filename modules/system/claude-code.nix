{ pkgs, ... }:

let
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
  # Claude Code and Plannotator are installed with their native installers
  # (run via nix-ld, on PATH via ~/.local/bin). Claude Code's system-wide
  # managed settings live here. They take precedence over
  # ~/.claude/settings.json, which Claude Code edits itself.
  environment.etc."claude-code/managed-settings.json".text = builtins.toJSON {
    # Register the Plannotator marketplace and install its Claude Code plugin
    # (slash commands and the plan-review hook) at the start of each session.
    extraKnownMarketplaces.plannotator = {
      source = {
        source = "github";
        repo = "backnotprop/plannotator";
      };
      autoUpdate = true;
    };
    enabledPlugins."plannotator@plannotator" = true;

    env = {
      # Plannotator on a headless server: use a fixed port range, advertise
      # the tailnet hostname, and hand the session URL to plannotator-open
      # instead of opening a browser.
      PLANNOTATOR_REMOTE = "1";
      PLANNOTATOR_PORT = "19432-19440";
      PLANNOTATOR_URL_HOST = "auto";
      PLANNOTATOR_BROWSER = "${plannotatorOpen}/bin/plannotator-open";
    };
  };

  # Also on PATH, for testing it by hand.
  environment.systemPackages = [ plannotatorOpen ];
}
