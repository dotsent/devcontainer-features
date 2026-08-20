# golang-migrate Dev Container Feature

Installs the official [`golang-migrate/migrate`](https://github.com/golang-migrate/migrate)
CLI into `/usr/local/bin`.

The Feature bundles static Linux binaries for `amd64` and `arm64`, replacing
architecture-specific `.deb` installation commands in devcontainer hooks.

```json
{
  "features": {
    "ghcr.io/dotsent/devcontainer-features/migrate:1": {}
  }
}
```

This Feature installs `migrate` v4.18.2.
