#!/bin/bash
set -e

source dev-container-features-test-lib

check "migrate is on PATH" command -v migrate
check "migrate version is 4.18.2" bash -c "migrate -version 2>&1 | grep -F '4.18.2'"
check "migrate license is installed" test -f /usr/local/share/licenses/migrate/LICENSE

reportResults
