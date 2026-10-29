#!/usr/bin/env bash
# Portable build of NASTRAN-95 with gfortran. Works on Linux, macOS and
# MSYS2 (MINGW64/UCRT64/CLANGARM64). Produces self-contained executables in
# $OUT (default: dist/bin) with the GCC/Fortran runtime linked in statically.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FC="${FC:-gfortran}"
OUT="${OUT:-$ROOT/dist/bin}"
OBJ="${OBJ:-$ROOT/build-release/obj}"
JOBS="${JOBS:-$( (nproc || sysctl -n hw.ncpu || echo 2) 2>/dev/null )}"

FFLAGS="${OPT:--O2} -w -std=legacy -fallow-invalid-boz -fallow-argument-mismatch -fdec"
case "$(uname -m)" in
  x86_64|AMD64) FFLAGS="$FFLAGS -mtune=generic" ;;
esac

# Static runtime flags
OS="$(uname -s)"
case "$OS" in
  Darwin)
    # macOS forbids fully static executables; link the GNU runtime libs statically.
    LDFLAGS="-static-libgfortran -static-libgcc -static-libquadmath"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    LDFLAGS="-static"
    ;;
  *)
    LDFLAGS="-static"
    ;;
esac

rm -rf "$OBJ"; mkdir -p "$OBJ" "$OUT"

compile_one() {
  src="$1"
  o="$OBJ/$(echo "$src" | tr '/' '_').o"
  "$FC" $FFLAGS -c "$src" -o "$o" 2> "$o.log" || { echo "FAILED: $src"; cat "$o.log"; return 1; }
}
export -f compile_one; export FC FFLAGS OBJ

LIBSRC=$( (ls mis/*.f mds/*.f; ls bd/*.f) | grep -v -e '^mds/chkfil.f$' -e '^mds/nastrn.f$' -e '^bd/semdbd.f$')
echo "$LIBSRC" | xargs -P "$JOBS" -I{} bash -c 'compile_one {}'

CC="${CC:-gcc}"
"$CC" -O2 -c bin/nsputenv.c -o "$OBJ/nsputenv.o"
echo "Linking..."
EXE=""; case "$OS" in MINGW*|MSYS*|CYGWIN*) EXE=".exe" ;; esac
# Archive (not loose objects): unreferenced, unfinished routines such as shtrmd.f
# (calls t6shpd/jacobd/q8shpd which do not exist in the source) are then never pulled in.
rm -f "$OBJ/libnas.a"
if [ -n "$EXE" ]; then
  (cd "$OBJ" && ls *.o | grep -v 'nsputenv.o' | grep -v '^bd_' > objects.rsp && ar rcs libnas.a @objects.rsp)
else
  ar rcs "$OBJ/libnas.a" "$OBJ"/mis_*.o "$OBJ"/mds_*.o "$OBJ"/bd_*.o
fi
# BLOCK DATA units are never referenced, so link the bd objects explicitly.
"$FC" $FFLAGS bin/nastrn.f "$OBJ/nsputenv.o" "$OBJ"/bd_*.o "$OBJ/libnas.a" $LDFLAGS -o "$OUT/nastran$EXE"
"$FC" $FFLAGS um/nasthelp.f $LDFLAGS -o "$OUT/nasthelp$EXE"
"$FC" $FFLAGS utility/nastplot.f $LDFLAGS -o "$OUT/nastplot$EXE"
"$FC" $FFLAGS mds/chkfil.f $LDFLAGS -o "$OUT/chkfil$EXE"
"$FC" $FFLAGS utility/ff.f "$OBJ"/bd_*.o "$OBJ/libnas.a" $LDFLAGS -o "$OUT/ff$EXE"
ls -l "$OUT"