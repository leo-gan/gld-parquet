# mojo-parquet

mojo-parquet is a from-scratch [Apache Parquet](https://parquet.apache.org/docs/file-format/) library for [Mojo](https://www.modular.com/mojo) 1.1.

The runtime reads and writes a Parquet file: the footer, row groups, column chunks, and data pages. A code generator turns a JSON Schema document into a Mojo struct. None of this code wraps a C, C++, or Rust Parquet library.

| Page | What it explains |
| --- | --- |
| [Why Parquet](why-parquet.md) | Columns, pages, and why the file is laid out that way. |
| [Instructions](instructions.md) | Install, import, and run the tests. |
| [Examples](examples.md) | A table and a generated struct. |
| [Techniques](techniques.md) | Encodings, compression, statistics, and limits. |
| [Test data](test-data.md) | The files checked into this repository. |
