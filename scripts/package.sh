#!/usr/bin/env bash
# Assemble a release bundle: static executables + the runtime data NASTRAN needs (rf/).
# usage: scripts/package.sh <platform-tag> <version>   e.g. linux-x86_64 v1.0.0
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
TAG="${1:?platform tag}"; VER="${2:-dev}"
NAME="nastran95-$VER-$TAG"
STAGE="dist/$NAME"
rm -rf "$STAGE"; mkdir -p "$STAGE/um"
cp dist/bin/* "$STAGE/"
cp -r rf "$STAGE/rf"
cp um/*.TXT "$STAGE/um/" 2>/dev/null || true
cp "NASA Open Source Agreement-NASTRAN 95.doc" "$STAGE/" 2>/dev/null || true
cat > "$STAGE/README.txt" <<'EOF'
NASTRAN-95 portable build (statically linked; no Fortran runtime needed).

Keep the "rf" folder next to the executable. Run from any directory:

    nastran < deck.inp > deck.out        (Windows: nastran.exe < deck.inp > deck.out)

Scratch files (scrNN) and the log (nastran.log) go to the current directory.
Optional overrides via environment variables: DBMEM, OCMEM, RFDIR, DIRCTY, LOGNM,
OPTPNM, NPTPNM, PLTNM, DICTNM, PUNCHNM, FTN11..FTN21, SOF1..SOF10.
EOF
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) (cd dist && zip -qr "$NAME.zip" "$NAME"); ASSET="$NAME.zip" ;;
  *) tar -C dist -czf "dist/$NAME.tar.gz" "$NAME"; ASSET="$NAME.tar.gz" ;;
esac
echo "dist/$ASSET"
