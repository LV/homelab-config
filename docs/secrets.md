# Secrets

_Stored on the server only, never in this repo._

## Hetzner DNS token

- **Path:** `/var/lib/secrets/hetzner-dns-token`
- **What:** Hetzner Console API token (Read & Write), from the project containing the `luis.vi` zone
- **Used by:** `hetzner-ddns` module

```bash
sudo install -d -m 700 /var/lib/secrets
sudo sh -c 'umask 077; cat > /var/lib/secrets/hetzner-dns-token'
# paste token, Enter, Ctrl+D
```
