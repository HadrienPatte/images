#!/usr/bin/env bash
set -euo pipefail

curl -s "https://api.github.com/repos/Sonarr/Sonarr/releases/latest" | jq -r '.tag_name'
