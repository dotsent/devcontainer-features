#!/bin/sh

set -eu

feature_dir="$(CDPATH= cd "$(dirname "$0")" && pwd)"
install_dir="${MIGRATE_INSTALL_DIR:-/usr/local/bin}"
license_dir="${MIGRATE_LICENSE_DIR:-/usr/local/share/licenses/migrate}"

if [ "$(uname -s)" != "Linux" ]; then
  echo "migrate Dev Container Feature supports Linux containers only" >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64 | amd64) asset_name="migrate-linux-amd64" ;;
  aarch64 | arm64) asset_name="migrate-linux-arm64" ;;
  *)
    echo "migrate does not provide a binary for architecture $(uname -m)" >&2
    exit 1
    ;;
esac

command -v sha256sum >/dev/null 2>&1 || {
  echo "migrate installation requires sha256sum" >&2
  exit 1
}

if [ ! -f "$feature_dir/bin/$asset_name" ] || [ ! -f "$feature_dir/SHA256SUMS" ]; then
  echo "migrate feature artifact is missing its bundled release assets" >&2
  exit 1
fi

if [ ! -f "$feature_dir/third-party/migrate-LICENSE" ]; then
  echo "migrate feature artifact is missing the upstream license" >&2
  exit 1
fi

(
  cd "$feature_dir/bin"
  sha256sum -c "$feature_dir/SHA256SUMS"
)

mkdir -p "$install_dir" "$license_dir"
cp "$feature_dir/bin/$asset_name" "$install_dir/migrate"
cp "$feature_dir/third-party/migrate-LICENSE" "$license_dir/LICENSE"
chmod 0755 "$install_dir/migrate"
chmod 0644 "$license_dir/LICENSE"

"$install_dir/migrate" -version >/dev/null 2>&1
