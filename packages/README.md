# Packages

Add one directory per package (or pkgbase), each containing a `PKGBUILD`.

GitHub Actions builds every `packages/*/PKGBUILD`, runs `repo-add`, and publishes
binaries to GitHub Pages.

## Current packages

| Package | Description |
|---------|-------------|
| [osu-winello](osu-winello/) | osu! stable (winello + wine-osu + prefix) |
