{ pkgs, ... }:

let
  zone = "luis.vi";
  record = "git";

  updateScript = pkgs.writeShellApplication {
    name = "hetzner-ddns";
    runtimeInputs = [ pkgs.curl pkgs.jq ];
    text = ''
      token="$(< "$CREDENTIALS_DIRECTORY/token")"
      api="https://api.hetzner.cloud/v1/zones/${zone}/rrsets/${record}/A"

      current_ip="$(curl -4 -fsS https://ifconfig.me)"
      if ! [[ $current_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Got an invalid public IP: '$current_ip'" >&2
        exit 1
      fi

      dns_ip="$(curl -fsS -H "Authorization: Bearer $token" "$api" \
        | jq -r '.rrset.records[0].value')"

      if [ "$current_ip" = "$dns_ip" ]; then
        echo "IP unchanged ($current_ip)"
        exit 0
      fi

      echo "Updating ${record}.${zone}: $dns_ip -> $current_ip"
      jq -n --arg ip "$current_ip" '{records: [{value: $ip}]}' \
        | curl -fsS -X POST \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/json" \
            --data @- \
            "$api/actions/set_records" > /dev/null
      echo "Done"
    '';
  };
in
{
  systemd.services.hetzner-ddns = {
    description = "Update Hetzner DNS record for ${record}.${zone}";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${updateScript}/bin/hetzner-ddns";
      LoadCredential = "token:/var/lib/secrets/hetzner-dns-token";
      DynamicUser = true;
    };
  };

  systemd.timers.hetzner-ddns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
    };
  };
}
