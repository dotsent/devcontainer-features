#!/bin/bash
set -e

source dev-container-features-test-lib

test_dir="$(CDPATH= cd "$(dirname "$0")" && pwd)"

check "promtool is on PATH" command -v promtool
check "promtool version is 3.12.0" bash -c "promtool --version | grep -F 'version 3.12.0'"
check "promtool validates rules" promtool check rules "$test_dir/valid-rules.yaml"
check "promtool license is installed" test -f /usr/local/share/licenses/promtool/LICENSE

reportResults
