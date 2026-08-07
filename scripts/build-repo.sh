#!/usr/bin/env bash
# Build every packages/*/PKGBUILD and assemble a pacman repository under ./repo/x86_64.
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
  echo "No packages/*/PKGBUILD found — creating an empty repository database."
else
  for pkgbuild in "${pkgbuilds[@]}"; do
    pkgdir="$(dirname "${pkgbuild}")"
    echo "==> Building $(basename "${pkgdir}")"
    (
      cd "${pkgdir}"
      # Drop prior artifacts so repo-add never picks stale packages.
      rm -f ./*.pkg.tar.zst ./*.pkg.tar.xz ./*.pkg.tar.gz
      makepkg -sf --noconfirm --needed
      shopt -s nullglob
      built_here=(./*.pkg.tar.zst ./*.pkg.tar.xz ./*.pkg.tar.gz)
      if ((${#built_here[@]} == 0)); then
        echo "error: makepkg produced no package archives in ${pkgdir}" >&2
        exit 1
      fi
      mv -v "${built_here[@]}" "${OUT}/"
    )
  done
fi

# Refresh the repository database from packages currently in OUT.
rm -f "${OUT}/${REPO_NAME}".db* "${OUT}/${REPO_NAME}".files*
mapfile -t built < <(find "${OUT}" -maxdepth 1 -type f \( -name '*.pkg.tar.zst' -o -name '*.pkg.tar.xz' -o -name '*.pkg.tar.gz' \) | sort)

db="${OUT}/${REPO_NAME}.db.tar.zst"
if ((${#built[@]} > 0)); then
  repo-add --new "${db}" "${built[@]}"
else
  # repo-add refuses an empty argument list; an empty ustar is a valid empty sync DB.
  tar -C "${OUT}" -c -T /dev/null | zstd -q -f -o "${db}"
  cp -a "${db}" "${OUT}/${REPO_NAME}.files.tar.zst"
  ln -sfn "${REPO_NAME}.db.tar.zst" "${OUT}/${REPO_NAME}.db"
  ln -sfn "${REPO_NAME}.files.tar.zst" "${OUT}/${REPO_NAME}.files"
fi

echo "==> Repository ready at ${OUT}"
ls -lah "${OUT}"
