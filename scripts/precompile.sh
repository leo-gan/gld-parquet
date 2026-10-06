#!/usr/bin/env bash
# Precompile published packages into /tmp/mojo-parquet-pkg.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
out="${MOJO_PARQUET_PKG:-/tmp/mojo-parquet-pkg}"
mkdir -p "$out"
if command -v pixi >/dev/null 2>&1; then
  MOJO=(pixi run mojo)
elif command -v mojo >/dev/null 2>&1; then
  MOJO=(mojo)
else
  echo "mojo not found; run scripts/ci-setup.sh" >&2
  exit 1
fi
"${MOJO[@]}" precompile -I src src/runtime -o "$out/runtime.mojoc"
"${MOJO[@]}" precompile -I src src/compress -o "$out/compress.mojoc"
"${MOJO[@]}" precompile -I src src/wire -o "$out/wire.mojoc"
"${MOJO[@]}" precompile -I src src/schema -o "$out/schema.mojoc"
"${MOJO[@]}" precompile -I src src/parquet -o "$out/parquet.mojoc"
"${MOJO[@]}" build -I src src/codegen/cli.mojo -o "$out/gld-parquetgen-mojo"
echo "wrote $out"
