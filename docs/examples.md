# Examples

## Read a file

`decode_table` reads the whole file into columns. Each leaf column stores its non-null values and, when the schema needs them, definition and repetition levels.

```mojo
from parquet import decode_table

def main() raises:
    var raw = open("testdata/opt_i32.parquet", "r").read_bytes()
    var table = decode_table(raw)
    print(table.nrows)
```

`table.cols.i64s` holds integer and boolean values. `table.cols.bits` holds float and double bit patterns. `table.cols.raw` and `table.cols.ends` hold byte arrays. A null is a definition level below the column's maximum, not a sentinel stored in the value array.

## Write a file

`encode_table` writes the columns already stored on a table. `WriteOpts` selects the codec, statistics, and checksums. The defaults are uncompressed data page v1, plain values (RLE for booleans), statistics on, and checksums on.

```mojo
from runtime.model import WriteOpts
from wire.decode import decode_table
from wire.encode import encode_table

def main() raises:
    var raw = open("testdata/opt_i32.parquet", "r").read_bytes()
    var table = decode_table(raw)
    var opts = WriteOpts()
    opts.codec = 1
    var out = encode_table(table, opts)
    print(len(out))
```

Codec `1` is Snappy. `2` is gzip, `6` is Zstd, and `7` is LZ4_RAW.

## Generated struct

`gld-parquetgen-mojo` emits a struct whose fields match the JSON Schema properties. `encode_to` appends one Parquet file to a byte list. `decode_from` reads the first row of a file back into the struct.
