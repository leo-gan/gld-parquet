# Why Parquet

A Parquet file stores each column together. A program that needs one column reads that column's pages and skips the rest. The footer, written at the end of the file, names the columns, the row groups, and the byte offsets of the pages.

Each column chunk is a sequence of pages. A page holds repetition levels, definition levels, and encoded values. Repetition levels rebuild lists. Definition levels mark nulls. The values themselves use a physical type such as `INT32` or `BYTE_ARRAY`, plus an optional logical type such as decimal, timestamp, or UTF-8.

## What this library covers

The implementation follows the Parquet file format as published at parquet.apache.org.

| Surface | Role |
| --- | --- |
| Physical types | Boolean, int32, int64, int96, float, double, byte array, and fixed-length byte array. |
| Logical types | String, enum, UUID, integer, decimal, date, time, timestamp, interval, JSON, BSON, float16, list, map, variant, geometry, geography, and file. |
| Pages | Data page v1, data page v2, and dictionary pages. |
| Encodings | Plain, dictionary, RLE, bit-packed levels, delta integer, delta length, delta byte array, byte stream split, and ALP. |
| Compression | Uncompressed, Snappy, gzip, Zstd, and LZ4_RAW. The deprecated Hadoop LZ4 codec is accepted on read. |
| Footer extras | Statistics, column orders, and page checksums on write. Column indexes, offset indexes, and Bloom filters on read. |

Two encodes of the same table with the same options produce the same bytes. PyArrow can read those bytes, and this library can read a PyArrow file for the features above.

Modular encryption is rejected. An encrypted footer uses the magic `PARE` and returns a version error. Geometry and geography values are stored as annotated byte arrays plus CRS metadata. This library does not interpret their coordinates.
