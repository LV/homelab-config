# Hostname Naming Scheme

**v1.0, October 30, 2026.** Tailnet: `gentoo-fahrenheit.ts.net`

This document has two parts. **Part 1** defines the permanent naming rules. The rules are frozen as of v1.0; the token registry, devices, reserved names, and retired names are maintained as the tailnet evolves. **Part 2 (operating notes)** describes how Tailscale behaves as of the date above and is updated whenever Tailscale changes.

# Part 1: Naming spec

Every name is permanent for the lifetime of the identity it represents. Physical names follow the hardware unit; VM names follow the provisioned VM instance; container names follow the persistent logical application instance. The model field classifies that identity (hardware model, OS family, or application); it is not the identity itself. Changing a VM's OS family or a container's application creates a new identity, and so does a repair that changes a device's hardware model.

Location, ownership, hosting arrangement (local, rented, cloud), workload role, and OS version are deployment attributes, not identity. They belong in inventory metadata (the Devices table). Role-based names for reaching things belong in reserved names.

**Terminology:** an *application* is software you run (Jellyfin, Grafana). A *Tailscale Service* (capital S) is the Tailscale feature that gives an application a stable tailnet name.

## Format

```
<class>-<model>-<nn>
```

Every hostname has exactly three fields and exactly two dashes. Dashes only ever separate fields; values inside a field never contain a dash.

Full address: `<class>-<model>-<nn>.gentoo-fahrenheit.ts.net`

## Fields

### class

A fixed three-letter code. The class also says how to read the model field.

| Code  | Identity                                                                  | Model field means |
|-------|---------------------------------------------------------------------------|-------------------|
| `lap` | Physical laptop                                                           | Hardware          |
| `dsk` | Physical desktop or workstation                                           | Hardware          |
| `srv` | Server-grade hardware: rackmount or server chassis, usually with IPMI/BMC | Hardware          |
| `sbc` | Single-board computer (e.g. Raspberry Pi)                                 | Hardware          |
| `phn` | Physical phone                                                            | Hardware          |
| `tab` | Physical tablet                                                           | Hardware          |
| `vrt` | Virtual machine                                                           | OS family         |
| `ctr` | Container with its own tailnet identity                                   | Application       |

Class follows form factor, never workload or ownership. A laptop running server workloads stays `lap`. Rented bare metal follows its physical hardware class: server-grade hardware is `srv`, desktop or workstation hardware is `dsk`. A rented VPS or cloud instance is `vrt`.

Applications running natively on a host (such as the NixOS applications on `lap-t480-01`) are not tailnet nodes: they get no hostname and consume no numbers, so adding, removing, or moving them never touches this scheme. `ctr` applies only when a container joins the tailnet as its own node.

Ephemeral containers are outside this scheme. They join with ephemeral auth keys, are not named under this scheme, and are never listed or retired.

New codes may be added, but existing codes are never changed or reused.

### model

One lowercase token with no dashes, read according to the class.

- **Physical devices:** the hardware model, squashed into one token (`t480`, `rpi5`). Self-built machines use the motherboard model. Apple laptops use product, screen size, and chip (`mbp16m1pro`), since Apple sells same-size models in the same year that differ only by chip.
- **Virtual machines:** the OS family, without a version (`nixos`, `debian`, `win`). A VM that changes OS family gets a new identity and name; an OS version upgrade does not. The host machine is never encoded, since VMs can migrate between hosts.
- **Containers:** the application the container runs (`jellyfin`). A container that switches to a different application is a new container with a new name.

Once a token is chosen, it is recorded in the registry and reused for all future devices of that kind.

### nn

At least two digits, counting up from `01` within each class-and-model pair; after `99` comes `100`. Because retired numbers are never reused, this counts every instance ever created, not just those running at once. It is always present, even when only one such device exists, so that a second one never forces a rename. A new device or instance always takes the next unused number, never a retired one.

For containers, each number is one persistent logical instance. Its Tailscale state preserves its tailnet registration; it does not define its identity.

## Rules

1. **Always include every field.** No shortened forms.
2. **Never encode deployment attributes.** The model field represents hardware for physical devices, the provisioned OS family for virtual machines, and the application for containers. Nothing else goes in a hostname.
3. **Never reuse a retired name.** A name is retired only when its identity is intentionally decommissioned or replaced: hardware sold or scrapped, VM destroyed, container instance deliberately torn down, or a change of VM OS family, container application, or hardware model. Accidental loss of Tailscale state never retires a name (rule 4). Retired names are listed below.
4. **Re-registering keeps the name.** If a device keeps its identity but loses its Tailscale state (OS reinstall, lost container volume), delete the old node in the admin console *before* re-registering. Otherwise Tailscale may assign a suffixed name (currently like `lap-t480-01-1`).
5. **A container rebuild preserves the node only if its Tailscale state persists.** The state must survive rebuilds and must never be shared between instances running at the same time. If state is lost, follow rule 4.
6. **Lowercase letters, digits, and dashes only.** Tailscale machine names are single DNS labels: no dots, no underscores, 63 characters maximum.
7. **Certificates are permanent public records.** Every name issued an HTTPS certificate is published in Certificate Transparency logs forever, including Tailscale Services served over HTTPS.
   - Set the final name before running `tailscale cert` or serving over HTTPS.
   - Ephemeral containers never request certificates.
   - Tailscale Service and container names reveal what you run, so only certify what you're comfortable disclosing.
8. **Reserved names are one lowercase word with no dashes.** Hostnames always have exactly two dashes, so a dashless name can never collide with one. Tailscale Services share the `*.gentoo-fahrenheit.ts.net` namespace with machines, so squash multi-word names: `homeassistant`, not `home-assistant`.
9. **SSH aliases and Tailscale Services share one reserved-name registry.** A name can mean only one destination or purpose, whichever mechanism provides it.

## Token registry

| Token        | Class | Meaning                                   |
|--------------|-------|-------------------------------------------|
| `mbp16m1pro` | `lap` | Apple MacBook Pro (16-inch, 2021), M1 Pro |
| `t480`       | `lap` | Lenovo ThinkPad T480                      |
| `nixos`      | `vrt` | NixOS                                     |
| `debian`     | `vrt` | Debian                                    |
| `win`        | `vrt` | Windows                                   |

## Devices

Inventory metadata lives here, not in hostnames.

| Hostname            | Device                           | OS    | Hosting | Tagged | Status |
|---------------------|----------------------------------|-------|---------|--------|--------|
| `lap-mbp16m1pro-01` | MacBook Pro 16-inch 2021, M1 Pro | macOS | Mobile  | No     | Active |
| `lap-t480-01`       | ThinkPad T480, Libreboot         | NixOS | Home    | No (planned before first Tailscale Service) | Active |

## Reserved names

| Name      | Points to     | Mechanism  | Scope                                       |
|-----------|---------------|------------|---------------------------------------------|
| `homelab` | `lap-t480-01` | SSH config | SSH only, on machines that have this config |

## Retired names

None yet. Names listed here must never be assigned again.

| Hostname | Retired | Reason |
|----------|---------|--------|

# Part 2: Operating notes (as of October 2026)

## Setting a hostname

**NixOS:**

```nix
networking.hostName = "lap-t480-01";
```

**macOS:**

```sh
sudo scutil --set HostName lap-mbp16m1pro-01
sudo scutil --set LocalHostName lap-mbp16m1pro-01
sudo scutil --set ComputerName lap-mbp16m1pro-01
```

**Tailscale (any OS):**

```sh
sudo tailscale set --hostname=lap-t480-01
```

## SSH aliases

For reaching a machine by its role over SSH. These don't resolve in browsers, `ping`, or anything else, and only work on machines that carry the config. In `~/.ssh/config`:

```
Host homelab
    HostName lap-t480-01.gentoo-fahrenheit.ts.net
```

## Key expiry

User-owned nodes expire periodically and drop off the tailnet until re-authenticated. For `lap-t480-01`, disable key expiry in the admin console (Machines page, machine menu, Disable key expiry).

## Application access tiers

Applications run natively on `lap-t480-01`, each on its own port. Every application gets exactly one tier, recorded in the port registry. Move an application toward Tier 1 if it becomes important, or toward Tier 3 if it doesn't need the exposure.

**Tier 1: Tailscale Service.** For applications whose clients are hard to reconfigure: phone and TV apps, browser extensions, and anything family members use (Jellyfin, a password manager, Home Assistant). These clients store a URL, so if the application moves to another host, nobody updates anything. Each one uses one of the 10 Tailscale Service slots available on every plan and publishes its name in CT logs, so keep this tier small.

**Tier 2: node port.** For admin UIs and tools only you use. Served on the node's own name with the application's own port, such as `https://lap-t480-01.gentoo-fahrenheit.ts.net:3000`. This needs only the node's one certificate, whose name reveals nothing about what you run. These URLs are tied to the hardware, which is fine for things only you bookmark.

```sh
tailscale serve --bg --https=3000 http://127.0.0.1:3000
```

**Tier 3: local only.** Not exposed to the tailnet at all.

### Setting up Tier 1

Only tagged devices can host Tailscale Services, so the first Tier 1 application means tagging `lap-t480-01`. Tagging moves the node's ownership from your user to the tag, so rules covering only your own devices (such as `autogroup:self`) stop applying to it.

0. **Record the name** in the Reserved names table (rule 9).
1. **Update the access policy first**, or you can lose SSH and Tier 2 access. Add the tag and a grant from your own user to it (replace the email with your Tailscale login):

   ```json
   "tagOwners": { "tag:server": ["autogroup:admin"] },
   "grants": [
     { "src": ["you@example.com"], "dst": ["tag:server"], "ip": ["*"] }
   ]
   ```

   This grants your user full access to the server. Review existing rules to make sure no broader rule also grants access to `tag:server`. Other people, such as family members, get access to individual Tailscale Services in step 5, never to `tag:server`. If you use Tailscale SSH (rather than regular OpenSSH), it also needs an `ssh` rule for `tag:server`.
2. **Tag the host** in the admin console (Machines page, machine menu, Edit ACL tags).
3. **Define the Tailscale Service** in the admin console (Services page).
4. **Approve the host** for the Tailscale Service, manually or through `autoApprovers`.
5. **Grant access** to the Tailscale Service, such as `"dst": ["svc:jellyfin"]`.
6. **Advertise it** from the host:

   ```sh
   tailscale serve --service=svc:jellyfin --https=443 http://127.0.0.1:8096
   ```

   This makes `https://jellyfin.gentoo-fahrenheit.ts.net` reachable regardless of which host serves it.

### Avoid

- **Path-based routing** on a shared name (`/grafana`, `/sonarr`). Many applications break without a base-URL setting.
- **Subdomain-style routing.** MagicDNS doesn't support wildcard subdomains under `ts.net`, so `grafana.homelab.gentoo-fahrenheit.ts.net` isn't possible.
- **A Tailscale Service named `homelab`.** Rule 9 forbids it, since the SSH alias holds that name.

### Binding

Every application binds to `127.0.0.1` and is exposed only through `tailscale serve`. Otherwise it also listens on whatever network the laptop is connected to. On NixOS, leave each application's `openFirewall` option off. If you ever run Docker, never use Compose `ports:` entries without a `127.0.0.1:` prefix (`127.0.0.1:8096:8096`): unprefixed entries bind to all interfaces and bypass the NixOS firewall.

### Port registry

Each application keeps a fixed local port, and ports never conflict on the same node. In Tier 2, the tailnet port matches the local port. Tier 1 Tailscale Services use HTTPS on 443. If an application moves to another host, it keeps its local port.

| Application | Local port | Tailnet port | Tier | Address |
|-------------|------------|--------------|------|---------|
| Forgejo     | 3000       | 3000         | 2    | `http://lap-t480-01.gentoo-fahrenheit.ts.net:3000` |

Add a row before deploying each application.
