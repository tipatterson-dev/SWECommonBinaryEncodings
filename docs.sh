#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "build" ]; then
    echo "Building docs to site/ ..."
    uv run --group docs mkdocs build
else
    echo "Starting dev server at http://localhost:8000 ..."
    uv run --group docs mkdocs serve
fi
