# mojo-parquet

A from-scratch Apache Parquet implementation for [Mojo](https://www.modular.com/mojo).
The runtime and the code generator are written in Mojo. They do not wrap, link,
or vendor the Arrow C++ library, parquet-mr, or any other C, C++, or Rust
Parquet library.

PyArrow is a **test oracle** only. It is not required to encode or decode at
runtime.

This repository is a standalone library. It is not part of any other project.

Documentation: [Why Parquet](https://leo-gan.github.io/gld-parquet/why-parquet/),
[Instructions](https://leo-gan.github.io/gld-parquet/instructions/),
[Examples](https://leo-gan.github.io/gld-parquet/examples/),
[Techniques](https://leo-gan.github.io/gld-parquet/techniques/),
[Test data](https://leo-gan.github.io/gld-parquet/test-data/).

## Install

Published package (linux-64) on [prefix.dev/leo-gan/leo-gan](https://prefix.dev/leo-gan/leo-gan):

```bash
pixi add --channel https://prefix.dev/leo-gan/leo-gan mojo-parquet
```

That installs `parquet.mojoc` and the `gld-parquetgen-mojo` CLI. It needs
`mojo-compiler` 1.1. After install, `from parquet import …` resolves with no
extra `-I`.

From a git checkout (development):

```bash
git clone https://github.com/leo-gan/gld-parquet.git
cd gld-parquet
pixi install
pixi run test
```

Local precompile (no conda install):

```bash
pixi run precompile
```

`from parquet import …` then resolves from `/tmp/mojo-parquet-pkg`
(`mojo run -I /tmp/mojo-parquet-pkg …`).

The recipe is `conda.recipe/recipe.yaml`. A GitHub Release on this repo builds
it and uploads it to the channel above.

## What it reads and writes

| Surface | Behavior |
| --- | --- |
| File | Magic `PAR1`, row groups, column chunks, and a Thrift compact footer. |
| Types | Physical types plus the logical types in the current Parquet spec, including lists, maps, decimals, and timestamps. |
| Encodings | Plain, dictionary, RLE, delta, byte stream split, and ALP on read. The default writer uses plain or RLE. |
| Compression | Snappy, gzip, Zstd, and LZ4_RAW, implemented in Mojo. |
| Schema | JSON Schema objects. `gld-parquetgen-mojo` emits structs with `encoded_len`, `encode_to`, and `decode_from`. |

The writer emits footer version 1. Two encodes of the same table match when the
options match. Nulls, field order, and logical types are kept.

## Layout

`src/parquet` is the public package. `src/runtime` holds the columnar values
and the Thrift compact codec. `src/wire` holds pages and the file footer.
`src/compress` holds Snappy, gzip, Zstd, and LZ4. `src/schema` and
`src/codegen` turn a schema into Mojo.

Requires **Mojo 1.1.0**.

## License

MIT. Copyright (c) 2026 Leonid Ganeline.
