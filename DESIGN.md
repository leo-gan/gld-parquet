# Design

mojo-parquet is a standalone Mojo 1.1 library. It implements the Apache Parquet
file format. PyArrow is a test oracle. The library does not link a C, C++, or
Rust Parquet implementation, and it does not depend on `mojo-arrow`.

## Decisions

| Topic | Choice |
| --- | --- |
| Surfaces | Columnar leaves with definition and repetition levels, a file reader, and a file writer. |
| Types | The physical types and the logical types in the current spec, including list, map, decimal, timestamp, variant, geometry, geography, and file. |
| Compression | Snappy, gzip, Zstd, and LZ4_RAW, written in Mojo. Deprecated Hadoop LZ4 is read. LZO, Brotli, and modular encryption are rejected. |
| API | `Table` and `Cols`, plus `gld-parquetgen-mojo`. |
| Schemas | The file footer, and the JSON Schema subset used by the other gld libraries, plus `x-parquet-type`. |
| Bytes | Logical values round-trip. Two encodes with the same options match. Page layout may differ from PyArrow. |
| Metadata | Hand-written Thrift compact protocol for the Parquet structs only. |
| Footer version | The writer emits 1. The reader accepts 1 and 2. |

## Layout

`Cols` stores each leaf in parallel arrays. Integer and boolean values are
`Int` entries. Floats are IEEE bits. Byte arrays are a byte buffer plus end
offsets. Definition and repetition levels are stored only when the schema
level is greater than zero.

The code generator emits a struct whose fields are the properties of a JSON
Schema object. `encode_bytes` builds a one-row file. `decode_from` reads that
file back through `decode_table`.

## Ship path

Version `0.1.0` is the first commit on `main`. A later speed change lands
through a pull request. `0.2.0` is the release published to prefix.dev channel
`leo-gan/leo-gan`. The required checks are named `Mojo tests` and `Docs build`.
