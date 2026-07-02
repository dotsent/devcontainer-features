#!/usr/bin/env bash
set -e

VERSION="${VERSION:-"1.13.0"}"

pkg_mgr_update() {
  if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
    apt-get update -y
  fi
}

check_packages() {
  if ! dpkg -s "$@" > /dev/null 2>&1; then
    pkg_mgr_update
    apt-get install -y --no-install-recommends "$@"
  fi
}

ARCH=$(uname -m)
case "$ARCH" in
  aarch64) BIN="websocat.aarch64-unknown-linux-musl" ;;
  x86_64)  BIN="websocat.x86_64-unknown-linux-musl" ;;
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;;
esac

check_packages curl ca-certificates

echo "Installing websocat v${VERSION} (${ARCH})..."

curl -fsSL "https://github.com/vi/websocat/releases/download/v${VERSION}/${BIN}" \
  -o /usr/local/bin/websocat

chmod +x /usr/local/bin/websocat

echo "Done: $(websocat --version)"
