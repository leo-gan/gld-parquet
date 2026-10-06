# Techniques

## File layout

A file starts and ends with the four bytes `PAR1`. Between them are the row groups, then optional page indexes and Bloom filters, then the Thrift compact footer, then a 4-byte little-endian footer length, then `PAR1` again.

The footer is a bare Thrift struct. Field ids are deltas packed into the high nibble of a header byte. This library writes that codec itself. It does not link a Thrift runtime.

The writer uses footer version 1. The reader accepts version 1 and version 2, which is what current PyArrow writes.

## Levels

A required leaf under the root has maximum definition level 0 and maximum repetition level 0. No level bytes are stored. An optional leaf has definition level 1. A list uses the standard three-level group: an optional list group, a repeated element group, and the element. Empty lists and null lists differ by definition level, so both survive a round trip.

## Encodings

Plain encoding stores values back to back. Booleans are packed from the least significant bit. Dictionary pages store plain values, and data pages store RLE indexes after a one-byte bit width. Delta encodings follow the Parquet block and miniblock layout, with 128 values per block and 4 miniblocks. The reader decodes ALP from its page header, offset array, and per-vector exceptions. The writer does not emit ALP pages.

## Compression

Page compression wraps the bytes the encoding produced. Snappy, gzip, Zstd, and LZ4_RAW are implemented in Mojo. Gzip readers accept several members and check the CRC-32 and ISIZE. Zstd frames that use raw or RLE blocks are written; compressed Zstd blocks from other writers are decoded.

## Statistics and indexes

When statistics are on, each column chunk records a null count and the minimum and maximum non-null values. Integer minimum and maximum are also written in the older `min` and `max` fields so older readers still see them. Floating columns record a NaN count.

Page checksums are CRC-32 of the stored page body, excluding the page header. A mismatch is a decode error. The reader accepts column indexes, offset indexes, and Bloom filters when a file contains them. The default writer does not emit those optional sections.

## Limits

| Limit | Value |
| --- | --- |
| Schema depth | 1024 |
| Decompressed page or codec output | 64 MiB, and the shared buffer cap is 256 MiB |
| Encryption | Rejected |
| LZO and Brotli | Rejected with a compression error |
