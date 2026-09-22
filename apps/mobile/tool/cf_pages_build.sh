#!/usr/bin/env bash
# Wrapper compatível para configurações antigas do dashboard Cloudflare.
# A implementação oficial e multiplataforma vive em scripts/build-flutter-site.mjs.

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
exec node "$REPO_ROOT/scripts/build-flutter-site.mjs"
