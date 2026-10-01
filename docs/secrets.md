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

## ntfy

### ntfy users and tokens

- **Path:** `/var/lib/secrets/ntfy.env`
- **What:** ntfy user (bcrypt password hash, admin role) and an access token for scripts
- **Used by:** `ntfy` module (`services.ntfy-sh.environmentFile`)

```bash
ntfy user hash        # prompts for a password, prints a $2a$... hash
ntfy token generate   # prints a random tk_... token

sudo sh -c 'umask 077; cat > /var/lib/secrets/ntfy.env'
# paste the lines below with real values, Enter, Ctrl+D
```

```
NTFY_AUTH_USERS='v:$2a$10$...:admin'
NTFY_AUTH_TOKENS='v:tk_...:scripts'
```

Keep the single quotes: the hash contains `$` characters.

### ntfy token for `notify`

- **Path:** `~/.config/ntfy/token` (user `v`)
- **What:** the ntfy access token from `/var/lib/secrets/ntfy.env`
- **Used by:** the `notify` command and `plannotator-open` (`claude-code` module)

```bash
mkdir -p ~/.config/ntfy
(umask 077; read -rs t; printf '%s\n' "$t" > ~/.config/ntfy/token)
# paste token, Enter
```

## Mullvad WireGuard config

- **Path:** `/var/lib/secrets/mullvad-wg.conf`
- **What:** Full WireGuard config from mullvad.net (Linux, us-nyc-wg-002,
  no kill switch, no content blocking). Must include `DNS = 10.64.0.1`
- **Used by:** `qbittorrent` module (VPN-Confinement namespace `mullvad`)

```bash
sudo sh -c 'umask 077; cat > /var/lib/secrets/mullvad-wg.conf'
# paste full .conf contents, Enter, Ctrl+D
```
