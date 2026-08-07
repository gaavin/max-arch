# max-arch

Personal Arch Linux package repository. PKGBUILDs live in this repo; GitHub Actions build packages and publish a pacman-compatible repository on GitHub Pages.

## Layout

```
packages/<pkgname>/PKGBUILD   # add packages here
scripts/build-repo.sh         # builds packages + runs repo-add
.github/workflows/            # CI → GitHub Pages
```

Published layout on Pages:

```
https://gaavin.github.io/max-arch/x86_64/
  *.pkg.tar.zst
  max-arch.db
  max-arch.files
```

## One-time GitHub setup

1. Create an empty GitHub repository named `max-arch` (public; Pages on free plans needs a public repo).
2. Push this project:

```bash
cd ~/Projects/max-arch
git remote add origin git@github.com:gaavin/max-arch.git
git add .
git commit -m "Initialize personal Arch Linux repository"
git push -u origin main
```

3. Enable Pages: **Settings → Pages → Build and deployment → Source: GitHub Actions**.
4. Run **Actions → Build pacman repository → Run workflow** (or push a change under `packages/`).

After a green run, the packages are at:

`https://gaavin.github.io/max-arch/x86_64/`

## Configure pacman on your machine

1. Edit pacman config:

```bash
sudoedit /etc/pacman.conf
```

2. Append this section at the bottom:

```ini
[max-arch]
SigLevel = Optional TrustAll
Server = https://gaavin.github.io/max-arch/$arch
```

`SigLevel = Optional TrustAll` is appropriate while packages are unsigned. You can add package signing later.

3. Sync and verify:

```bash
sudo pacman -Sy
pacman -Sl max-arch
```

With no packages yet, `pacman -Sl max-arch` lists an empty repo — that means the mirror is reachable.

4. Install packages once you add them:

```bash
sudo pacman -Syu <pkgname>
```

### Optional: drop-in file instead of editing pacman.conf

```bash
sudo cp ~/Projects/max-arch/pacman-max-arch.conf /etc/pacman.d/max-arch.conf
# Then Include it from /etc/pacman.conf:
# Include = /etc/pacman.d/max-arch.conf
```

## Packages

### osu-winello

osu! stable via [osu-winello](https://github.com/NelloKudo/osu-winello), split into:

- `osu-winello` — launcher, yawl, MIME/handlers
- `wine-osu-winello` — patched wine-osu (`/opt/wine-osu`)
- `osu-winello-prefix` — prebuilt Wineprefix template

```bash
sudo pacman -Syu osu-winello
osu-winello    # first-time setup (as your user)
osu-wine       # play
```

See [packages/osu-winello/README.md](packages/osu-winello/README.md).

## Adding packages

```bash
mkdir -p packages/hello-world
# write packages/hello-world/PKGBUILD
git add packages/hello-world
git commit -m "Add hello-world"
git push
```

CI builds every `packages/*/PKGBUILD`, runs `repo-add`, and republishes Pages.

## Local build (optional)

On Arch:

```bash
./scripts/build-repo.sh
# output → ./repo/x86_64/
```

## Notes

- Repository name in pacman (`[max-arch]`) must match the database basename produced by `scripts/build-repo.sh` (`REPO_NAME`, default `max-arch`).
- Packages are currently **unsigned**. Do not reuse this `SigLevel` for third-party repos you do not control.
- GitHub Pages for this project is served under `https://gaavin.github.io/max-arch/`.
