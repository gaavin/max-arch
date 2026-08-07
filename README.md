# max-arch

Personal Arch Linux package repo. PKGBUILDs in `packages/`; CI publishes to GitHub Pages.

```
Server = https://gaavin.github.io/max-arch/$arch
```

## pacman

```ini
[max-arch]
SigLevel = Optional TrustAll
Server = https://gaavin.github.io/max-arch/$arch
```

```bash
sudo pacman -Sy
pacman -Sl max-arch
```

## Publish

```bash
git push
# Settings → Pages → Source: GitHub Actions (once)
```

## Packages

**osu-stable** — osu! stable

```bash
sudo pacman -Syu osu-stable
osu-stable
```

See [packages/osu-stable](packages/osu-stable/).

## Add a package

Drop a `PKGBUILD` under `packages/<name>/` and push. Local build: `./scripts/build-repo.sh`.

CI only rebuilds a package when its package-dir fingerprint changes; otherwise it reuses
binaries from Pages. Force a full rebuild via Actions → Run workflow → force_rebuild.

Unsigned repo (`Optional TrustAll`) — fine for this mirror only.

## Credits

- [NelloKudo/osu-winello](https://github.com/NelloKudo/osu-winello) — osu! stable Linux installer this packaging is based on
- [NelloKudo/WineBuilder](https://github.com/NelloKudo/WineBuilder) — patched wine-osu builds
- [whrvt/yawl](https://github.com/whrvt/yawl) — Wine / Steam Runtime launcher
- [EnderIce2/rpc-bridge](https://github.com/EnderIce2/rpc-bridge) — Discord RPC (on demand)
- [openglfreak/osu-handler-wine](https://github.com/openglfreak/osu-handler-wine) — beatmap/skin/url handler
- [ppy](https://osu.ppy.sh/) — osu!
