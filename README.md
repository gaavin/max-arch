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

**osu-winello** — osu! stable ([upstream](https://github.com/NelloKudo/osu-winello))

```bash
sudo pacman -Syu osu-winello
osu-wine
```

See [packages/osu-winello](packages/osu-winello/).

## Add a package

Drop a `PKGBUILD` under `packages/<name>/` and push. Local build: `./scripts/build-repo.sh`.

Unsigned repo (`Optional TrustAll`) — fine for this mirror only.
