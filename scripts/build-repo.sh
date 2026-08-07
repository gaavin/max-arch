#!/usr/bin/env bash
# Build packages/*/PKGBUILD → ./repo/x86_64 + repo-add
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_NAME="${REPO_NAME:-max-arch}"
ARCH="${ARCH:-x86_64}"
OUT="${ROOT}/repo/${ARCH}"
PACKAGES_DIR="${ROOT}/packages"

mkdir -p "${OUT}"

shopt -s nullglob
pkgbuilds=("${PACKAGES_DIR}"/*/PKGBUILD)

if ((${#pkgbuilds[@]} == 0)); then
  echo "No PKGBUILDs — empty repo db"
else
  for pkgbuild in "${pkgbuilds[@]}"; do
    pkgdir="$(dirname "${pkgbuild}")"
    echo "==> Building $(basename "${pkgdir}")"
    (
      cd "${pkgdir}"
      rm -f ./*.pkg.tar.zst ./*.pkg.tar.xz ./*.pkg.tar.gz
      makepkg -sf --noconfirm --needed
      shopt -s nullglob
      built_here=(./*.pkg.tar.zst ./*.pkg.tar.xz ./*.pkg.tar.gz)
      if ((${#built_here[@]} == 0)); then
        echo "error: no package in ${pkgdir}" >&2
        exit 1
      fi
      mv -v "${built_here[@]}" "${OUT}/"
    )
  done
fi

rm -f "${OUT}/${REPO_NAME}".db* "${OUT}/${REPO_NAME}".files*
mapfile -t built < <(find "${OUT}" -maxdepth 1 -type f \( -name '*.pkg.tar.zst' -o -name '*.pkg.tar.xz' -o -name '*.pkg.tar.gz' \) | sort)

db="${OUT}/${REPO_NAME}.db.tar.zst"
if ((${#built[@]} > 0)); then
  repo-add --new "${db}" "${built[@]}"
else
  tar -C "${OUT}" -c -T /dev/null | zstd -q -f -o "${db}"
  cp -a "${db}" "${OUT}/${REPO_NAME}.files.tar.zst"
  ln -sfn "${REPO_NAME}.db.tar.zst" "${OUT}/${REPO_NAME}.db"
  ln -sfn "${REPO_NAME}.files.tar.zst" "${OUT}/${REPO_NAME}.files"
fi

echo "==> ${OUT}"
ls -lah "${OUT}"
