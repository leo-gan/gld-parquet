from std.time import perf_counter_ns

from runtime.model import WriteOpts
from wire.decode import decode_table
from wire.encode import encode_table


def main() raises:
    var raw = open("testdata/snappy_i32.parquet", "r").read_bytes()
    var opts = WriteOpts()
    opts.codec = 1
    var i = 0
    var t0 = perf_counter_ns()
    var n = 0
    while i < 4000:
        var table = decode_table(raw)
        var out = encode_table(table, opts)
        n += len(out)
        i += 1
    var t1 = perf_counter_ns()
    var ms = (t1 - t0) / 1000000
    print(ms, n)
