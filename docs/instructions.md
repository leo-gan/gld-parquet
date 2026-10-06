# Instructions

The package name is `mojo-parquet`. The Mojo import is `parquet`. The code generator command is `gld-parquetgen-mojo`.

## Develop from this repository

Mojo is pinned to 1.1.0. Pixi installs it from the Modular channel. If that channel returns 401, put `PREFIX_API_KEY` in a local `.env` file and run the setup script again. Do not commit `.env`.

```bash
git clone https://github.com/leo-gan/gld-parquet.git
cd gld-parquet
bash scripts/ci-setup.sh
pixi run test
```

`pixi run test` compiles every file in `tests/`. `pixi run check-generated` regenerates `tests/generated/` and diffs it. `pixi run precompile` writes `.mojoc` packages under `/tmp/mojo-parquet-pkg`.

## Published package

The linux-64 package is on the prefix.dev channel `leo-gan/leo-gan`.

```bash
pixi add --channel https://prefix.dev/leo-gan/leo-gan mojo-parquet
```

That install provides `parquet.mojoc` and `gld-parquetgen-mojo`. It needs `mojo-compiler` 1.1.

## Generate a struct

`testdata/schema/record.json` is a JSON Schema object. `x-parquet-type` selects the Parquet logical type when the JSON type is not enough. The `title` field names the generated struct.

```bash
pixi run mojo run -I src src/codegen/cli.mojo -- \
  --schema testdata/schema/record.json --out tests/generated
```

The struct `Record` has `encoded_len`, `encode_to`, and `decode_from`. `encode_bytes` returns one Parquet file that holds a single row.
