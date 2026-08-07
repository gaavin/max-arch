# max-arch

Personal Arch Linux package repo. PKGBUILDs in `packages/`; CI publishes signed packages to GitHub Pages.

```
Server = https://gaavin.github.io/max-arch/$arch
```

## pacman

Import and locally sign the repo key, then add the repository:

```bash
curl -fsSL https://gaavin.github.io/max-arch/max-arch.gpg | sudo pacman-key --add -
sudo pacman-key --lsign-key FDEA10C7977894F8E6C5C7DE81E5300762ECD71E
```

```ini
[max-arch]
SigLevel = Required
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

CI signs packages and the repo database with the key in `keys/`. The private key lives only as the
GitHub Actions secret `MAX_ARCH_GPG_PRIVATE_KEY` (never commit it).

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
binaries (and `.sig` files) from Pages. Force a full rebuild via Actions → Run workflow → force_rebuild.

Local unsigned smoke build: `SIGN_PACKAGES=0 ./scripts/build-repo.sh`.
