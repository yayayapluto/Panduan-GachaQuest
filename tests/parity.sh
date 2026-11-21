#!/bin/sh
# Membandingkan output bin/game dengan golden transcript di tests/out_golden.txt.
# Jalankan dari mana saja: sh tests/parity.sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
NAME="game"
[ -x "$ROOT/bin/game" ] || NAME="game.exe"
BIN="$ROOT/bin/$NAME"

if [ ! -x "$BIN" ]; then
    echo "GAGAL: $BIN tidak ada. Jalankan make dulu." >&2
    exit 2
fi

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t gqparity)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

mkdir -p "$TMP/bin" "$TMP/data"
cp "$BIN" "$TMP/bin/$NAME"
cp "$ROOT/data/item.txt" "$ROOT/data/monster.txt" "$TMP/data/"
cp "$ROOT/tests/in_golden.txt" "$TMP/in.txt"

(cd "$TMP" && "./bin/$NAME" < in.txt > out_raw.txt 2>&1) || true
tr -d '\r' < "$TMP/out_raw.txt" > "$TMP/out.txt"

if diff -u "$ROOT/tests/out_golden.txt" "$TMP/out.txt"; then
    echo "PARITAS OK: output sama dengan tests/out_golden.txt"
    exit 0
fi

echo "PARITAS GAGAL: selisih di atas. Perbaiki tampilan atau alur yang berbeda." >&2
exit 1
