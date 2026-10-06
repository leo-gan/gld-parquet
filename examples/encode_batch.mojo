from parquet import WriteOpts, decode_table, encode_table


def main() raises:
    var raw = open("testdata/opt_i32.parquet", "r").read_bytes()
    var table = decode_table(raw)
    var opts = WriteOpts()
    var out = encode_table(table, opts)
    print(table.nrows, len(out))
