# osu-winello (max-arch)

Arch packaging of [osu-winello](https://github.com/NelloKudo/osu-winello): osu! stable under patched wine-osu, launched through yawl/Steam Runtime.

## Packages

| Package | Contents |
|---------|----------|
| `wine-osu-winello` | Patched wine-osu → `/opt/wine-osu` (~wine-osu-staging 11.12-1) |
| `osu-winello-prefix` | Prebuilt Wineprefix template |
| `osu-winello` | Scripts, yawl, MIME/handlers, `/usr/bin/osu-wine`, `/usr/bin/osu-winello` |

`osu-winello` depends on the other two.

## Install (from max-arch)

```bash
sudo pacman -Syu osu-winello
```

## First-time setup

As your normal user (not root):

```bash
osu-winello
```

This wires yawl’s Steam Runtime, installs the Wineprefix into
`~/.local/share/wineprefixes/osu-wineprefix`, and downloads/installs osu!.

Then:

```bash
osu-wine
```

## Notes

- Wine/scripts update via **pacman**, not `osu-wine --update` wine re-downloads.
- Optional tools (tosu, gosumemory, mapping tools, Discord RPC) still download on demand when you use those `osu-wine` flags.
- Config: `~/.local/share/osuconfig/configs/` (see packaged `example.cfg`).
