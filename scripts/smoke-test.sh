#!/usr/bin/env bash
# Smoke test: run a bundled demo deck with the standalone executable, from a
# neutral directory, and require a clean finish.
# usage: scripts/smoke-test.sh <dir-containing-nastran-and-rf> [deck]
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE="$(cd "${1:?bundle dir}" && pwd)"
DECK="${2:-d01000a}"
EXE="$BUNDLE/nastran"; [ -x "$EXE" ] || EXE="$BUNDLE/nastran.exe"
W="$(mktemp -d)"; cd "$W"
cp "$ROOT/inp/$DECK.inp" .
timeout 600 "$EXE" < "$DECK.inp" > "$DECK.out" 2> "$DECK.err"; rc=$?
echo "exit code: $rc, output lines: $(wc -l < "$DECK.out")"
tail -5 "$DECK.err"
if [ $rc -ne 0 ] || grep -q 'FATAL' "$DECK.out" || [ "$(wc -l < "$DECK.out")" -lt 50 ]; then
  echo "SMOKE TEST FAILED"; tail -30 "$DECK.out"; exit 1
fi
echo "SMOKE TEST PASSED"
