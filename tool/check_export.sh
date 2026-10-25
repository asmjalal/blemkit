#!/usr/bin/env bash
# Exports every bundled template and runs `flutter analyze` on the generated code.
# Usage: tool/check_export.sh [template_name]
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="${EXPORT_OUT:-build/export_check}"
rm -rf "$OUT"
mkdir -p "$OUT"
EXPORT_DIR="$PWD/$OUT" flutter test test/generators > "$OUT/generate.log" 2>&1 || { tail -40 "$OUT/generate.log"; exit 1; }

status=0
for dir in "$OUT"/*/; do
  name="$(basename "$dir")"
  if [ -n "${1:-}" ] && [ "$1" != "$name" ]; then continue; fi
  (cd "$dir" && (flutter pub get --offline > /dev/null 2>&1 || flutter pub get > /dev/null 2>&1)) || { echo "pub get failed: $name"; status=1; continue; }
  errors="$(cd "$dir" && flutter analyze --no-pub 2>&1 | grep -E '^\s*error' || true)"
  if [ -n "$errors" ]; then
    echo "FAIL $name ($(echo "$errors" | wc -l | tr -d ' ') errors)"
    echo "$errors" | head -15
    status=1
  else
    echo "OK   $name"
  fi
done
exit $status
