# Secrets

_Stored on the server only, never in this repo._

## ntfy

### ntfy users and tokens

- **Path:** `/var/lib/secrets/ntfy.env`
- **What:** ntfy user (bcrypt password hash, admin role) and an access token for scripts
- **Used by:** `ntfy` module (`services.ntfy-sh.environmentFile`)

```bash
ntfy user hash        # prompts for a password, prints a $2a$... hash
ntfy token generate   # prints a random tk_... token

sudo install -d -m 700 /var/lib/secrets
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
- **Used by:** the `notify` command

```bash
mkdir -p ~/.config/ntfy
(umask 077; read -rs t; printf '%s\n' "$t" > ~/.config/ntfy/token)
# paste token, Enter
```

### alertmanager-ntfy token

- **Path:** `/var/lib/secrets/alertmanager-ntfy.yml`
- **What:** the ntfy access token from `/var/lib/secrets/ntfy.env`, as a YAML
  snippet merged into the bridge's config
- **Used by:** `alerting` module (`services.prometheus.alertmanager-ntfy.extraConfigFiles`)

```bash
sudo sh -c 'umask 077; cat > /var/lib/secrets/alertmanager-ntfy.yml'
# paste the lines below with the real token, Enter, Ctrl+D
```

```yaml
ntfy:
  auth:
    token: tk_...
```

## Forgejo runner

- **Path:** `/var/lib/secrets/forgejo-runner-token`
- **What:** the runner's token, alone on one line (no `TOKEN=`)
- **Used by:** `forgejo-runner` module (systemd credential `token`)

In Forgejo: Site administration → Actions → Runners → Create new runner
(name `lap-t480-01`). It shows a UUID and a token. The UUID goes in
`modules/system/forgejo-runner.nix` (not secret); the token goes here:

```bash
sudo sh -c 'umask 077; cat > /var/lib/secrets/forgejo-runner-token'
# paste token, Enter, Ctrl+D
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

## Grafana

- **Paths:** `/var/lib/secrets/grafana-admin-password`, `/var/lib/secrets/grafana-secret-key`
- **What:** the initial password for Grafana's admin user (`v`), and the key Grafana
  encrypts stored credentials with
- **Used by:** `grafana` module (passed to `grafana.service` as systemd credentials)

Both are generated automatically by `grafana-secrets.service` the first time
Grafana starts; nothing to create by hand. Existing files are never overwritten.

```bash
sudo cat /var/lib/secrets/grafana-admin-password   # log in as v
```

The password file is only the **initial** password: Grafana applies it once,
when it creates the admin user. After changing the password in the UI, the
file is stale. Never change or delete the secret key, or Grafana can no longer
decrypt data it stored. Back up both files together with `/var/lib/grafana`.
