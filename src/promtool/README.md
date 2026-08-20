# Prometheus promtool Dev Container Feature

Installs the official [`promtool`](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/#syntax-checking-rules)
binary into `/usr/local/bin`.

The Feature bundles static Linux binaries for `amd64` and `arm64`, so the
target devcontainer does not need Go, Docker, or access to GitHub Releases
during its build.

```json
{
  "features": {
    "ghcr.io/dotsent/devcontainer-features/promtool:1": {}
  }
}
```

Validate a Prometheus rule file with:

```sh
promtool check rules path/to/rules.yaml
```

This Feature installs `promtool` v3.12.0.
