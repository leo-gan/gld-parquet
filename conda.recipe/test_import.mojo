from std.collections import List

from parquet import DecodeError, WriteOpts, decode_table


def main() raises:
    var raw = List[Byte]()
    raw.append(Byte(80))
    raw.append(Byte(65))
    raw.append(Byte(82))
    raw.append(Byte(49))
    _ = raw
    var opts = WriteOpts()
    if opts.codec != 0:
        raise Error("default codec")
    print("parquet import ok", DecodeError.KIND_EOF)
