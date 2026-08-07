#!/usr/bin/env bash
# Build packages/*/PKGBUILD → ./repo/$ARCH + repo-add
# Unchanged pkgbases reuse binaries from the live Pages repo (fingerprints.tsv).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_NAME="${REPO_NAME:-max-arch}"
ARCH="${ARCH:-x86_64}"
OUT="${ROOT}/repo/${ARCH}"
PACKAGES_DIR="${ROOT}/packages"
CACHE="${ROOT}/.repo-cache/${ARCH}"
PAGES_URL="${PAGES_URL:-https://gaavin.github.io/max-arch}"
FORCE_REBUILD="${FORCE_REBUILD:-0}"
FINGERPRINTS_NAME="fingerprints.tsv"

mkdir -p "${OUT}" "${CACHE}"

fingerprint_pkgdir() {
  local dir="$1"
  (
    cd "$dir"
    find . -type f \
      ! -path './src/*' ! -path './pkg/*' \
      ! -name '*.pkg.tar.zst' ! -name '*.pkg.tar.xz' ! -name '*.pkg.tar.gz' \
      ! -name '.SRCINFO' \
      -print0 | sort -z | xargs -0 sha256sum
  ) | sha256sum | awk '{print $1}'
}

lookup_fingerprint() {
  local pkgbase="$1" file="$2"
  [[ -f "$file" ]] || return 1
  awk -F'\t' -v p="$pkgbase" '$1 == p { print $2; found=1; exit } END { exit !found }' "$file"
}

fetch_live_fingerprints() {
  local url="${PAGES_URL}/${ARCH}/${FINGERPRINTS_NAME}"
  if [[ -z "${PAGES_URL}" ]]; then
    echo "PAGES_URL empty — building all packages"
    : >"${CACHE}/${FINGERPRINTS_NAME}"
    return 0
  fi
  if curl -fsSL --retry 3 --retry-delay 2 "$url" -o "${CACHE}/${FINGERPRINTS_NAME}"; then
    echo "Fetched live fingerprints from ${url}"
  else
    echo "No live fingerprints at ${url} — building all packages"
    : >"${CACHE}/${FINGERPRINTS_NAME}"
  fi
}

download_pkg_from_pages() {
  local pkgfile="$1"
  local url="${PAGES_URL}/${ARCH}/${pkgfile}"
  echo "  reusing ${pkgfile}"
  curl -fsSL --retry 3 --retry-delay 2 "$url" -o "${OUT}/${pkgfile}"
}

build_pkgbase() {
  local pkgdir="$1"
  (
    cd "${pkgdir}"
    rm -f ./*.pkg.tar.zst ./*.pkg.tar.xz ./*.pkg.tar.gz
    makepkg -sf --noconfirm --needed
    shopt -s nullglob
    local built_here=(./*.pkg.tar.zst ./*.pkg.tar.xz ./*.pkg.tar.gz)
    if ((${#built_here[@]} == 0)); then
      echo "error: no package produced in ${pkgdir}" >&2
      exit 1
    fi
    mv -v "${built_here[@]}" "${OUT}/"
  )
}

try_reuse_pkgbase() {
  local pkgdir="$1"
  local -a packagelist=()
  mapfile -t packagelist < <(cd "${pkgdir}" && makepkg --packagelist)
  if ((${#packagelist[@]} == 0)); then
    return 1
  fi
  local pkgfile basename_pkg
  for pkgfile in "${packagelist[@]}"; do
    basename_pkg="$(basename "$pkgfile")"
    download_pkg_from_pages "$basename_pkg" || return 1
  done
  return 0
}

fetch_live_fingerprints

: >"${CACHE}/fingerprints.new"
shopt -s nullglob
pkgbuilds=("${PACKAGES_DIR}"/*/PKGBUILD)

if ((${#pkgbuilds[@]} == 0)); then
  echo "No PKGBUILDs — empty repo db"
else
  for pkgbuild in "${pkgbuilds[@]}"; do
    pkgdir="$(dirname "${pkgbuild}")"
    pkgbase="$(basename "${pkgdir}")"
    fp="$(fingerprint_pkgdir "${pkgdir}")"
    old_fp="$(lookup_fingerprint "${pkgbase}" "${CACHE}/${FINGERPRINTS_NAME}" || true)"

    echo "==> ${pkgbase}  fingerprint=${fp:0:12}…"

    if [[ "${FORCE_REBUILD}" != "1" && -n "${old_fp}" && "${old_fp}" == "${fp}" ]]; then
      if try_reuse_pkgbase "${pkgdir}"; then
        echo "    unchanged — reused from Pages"
        printf '%s\t%s\n' "${pkgbase}" "${fp}" >>"${CACHE}/fingerprints.new"
        continue
      fi
      echo "    fingerprint matched but download failed — rebuilding"
    elif [[ "${FORCE_REBUILD}" == "1" ]]; then
      echo "    FORCE_REBUILD=1 — rebuilding"
    elif [[ -z "${old_fp}" ]]; then
      echo "    no prior fingerprint — building"
    else
      echo "    fingerprint changed — rebuilding"
    fi

    build_pkgbase "${pkgdir}"
    printf '%s\t%s\n' "${pkgbase}" "${fp}" >>"${CACHE}/fingerprints.new"
  done
fi

cp "${CACHE}/fingerprints.new" "${OUT}/${FINGERPRINTS_NAME}"

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
