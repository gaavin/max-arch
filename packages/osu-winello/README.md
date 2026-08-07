# osu-winello

[Upstream](https://github.com/NelloKudo/osu-winello). Split as:

- `wine-osu-winello` — `/opt/wine-osu`
- `osu-winello-prefix` — Wineprefix tarball
- `osu-winello` — launcher / yawl / MIME (`depends` on the above)

```bash
sudo pacman -Syu osu-winello
osu-wine   # first run does setup, then launches
```

Configs: `~/.local/share/osuconfig/configs/`. Wine updates via pacman, not `osu-wine --update`.
