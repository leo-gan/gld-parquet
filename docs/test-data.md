# Test data

The files under `testdata/` are small Parquet files produced by PyArrow 25. The unit tests decode them and, for a subset, encode them again and decode the result.

| File | What it checks |
| --- | --- |
| `opt_i32.parquet` | Optional int32, one null, plain encoding, no compression. |
| `required_i64.parquet` | A non-null int64 field. |
| `strings.parquet` | Optional UTF-8 byte arrays. |
| `dict_str.parquet` | Dictionary indexes and a null. |
| `bools.parquet` | Optional booleans. |
| `floats.parquet` | Float64, negative zero, and NaN. |
| `list_i32.parquet` | A list column, including null and empty lists. |
| `struct.parquet` | A struct with an int and a string. |
| `map.parquet` | A map from string to int32. |
| `decimal.parquet` | Decimal128 stored as a fixed-length byte array. |
| `ts.parquet` | Timestamp in microseconds, adjusted to UTC. |
| `date.parquet` | Date stored as days. |
| `v2.parquet` | Data page v2 and a page index. |
| `multi_rg.parquet` | Several row groups. |
| `bss.parquet` | Byte stream split on float32. |
| `snappy_i32.parquet`, `gzip_i32.parquet`, `zstd_i32.parquet`, `lz4_i32.parquet` | The four compression codecs. |

`testdata/schema/record.json` is the JSON Schema input for `gld-parquetgen-mojo`. The checked-in generator output is `tests/generated/`.

PyArrow is a test oracle. It is not linked into the library and it is not required to encode or decode.
