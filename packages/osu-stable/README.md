# osu-stable

osu! stable for Arch, packaged from [osu-winello](https://github.com/NelloKudo/osu-winello).

## Packages

- `wine-osu-stable` — `/opt/wine-osu`
- `osu-stable-prefix` — Wineprefix tarball
- `osu-stable` — launcher / yawl / MIME

```bash
sudo pacman -Syu osu-stable
osu-stable
```

First run sets up the prefix and installs osu!. Config: `~/.local/share/osuconfig/configs/`.

Beatmap / skin / replay files and `osu://` links reuse a running game when possible.
Imports are staged under the game drive (same fix as [nix-osu-stable](https://github.com/gaavin/nix-osu-stable)) so Wine can move them into Songs.

## Credits

- [NelloKudo/osu-winello](https://github.com/NelloKudo/osu-winello) — installer, launcher, handlers, and packaging approach this package is based on
- [NelloKudo/WineBuilder](https://github.com/NelloKudo/WineBuilder) — patched wine-osu builds
- [whrvt/yawl](https://github.com/whrvt/yawl) — Wine launcher / Steam Runtime wrapper
- [EnderIce2/rpc-bridge](https://github.com/EnderIce2/rpc-bridge) — Discord RPC (installed on demand by winello)
- [openglfreak/osu-handler-wine](https://github.com/openglfreak/osu-handler-wine) — osu! file/url handler
- osu! — [ppy](https://osu.ppy.sh/)
