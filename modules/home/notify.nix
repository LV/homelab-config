{ pkgs, ... }:

let
  notify = pkgs.writeShellApplication {
    name = "notify";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      token_file="$HOME/.config/ntfy/token"
      if [ ! -r "$token_file" ]; then
        echo "notify: missing token file $token_file" >&2
        exit 1
      fi

      message="''${*:-Done}"

      curl -fsS \
        -H "Authorization: Bearer $(< "$token_file")" \
        -H "Title: $HOSTNAME" \
        -d "$message" \
        https://ntfy.luis.vi/homelab > /dev/null
    '';
  };
in
{
  home.packages = [ notify ];
}
