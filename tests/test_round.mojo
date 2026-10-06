from std.collections import List, Span

from runtime.model import WriteOpts
from wire.decode import decode_table
from wire.encode import encode_table


def same_i(a_b: Int, a_n: Int, b_b: Int, b_n: Int, a: List[Int], b: List[Int]) raises:
    if a_n != b_n:
        raise Error("count")
    var i = 0
    while i < a_n:
        if a[a_b + i] != b[b_b + i]:
            raise Error("value")
        i += 1


def round_one(path: String) raises:
    var raw = open(path, "r").read_bytes()
    var t = decode_table(raw)
    var opts = WriteOpts()
    var out = encode_table(t, opts)
    var back = decode_table(Span(out))
    if back.nrows != t.nrows or back.foot.schema.nleaves != t.foot.schema.nleaves:
        raise Error(path)
    var leaf = 0
    while leaf < t.foot.schema.nleaves:
        if t.cols.val_n[leaf] != back.cols.val_n[leaf]:
            raise Error(path)
        if t.cols.level_n[leaf] != back.cols.level_n[leaf]:
            raise Error(path)
        var lv = 0
        while lv < t.cols.level_n[leaf]:
            if t.cols.defs[t.cols.level_b[leaf] + lv] != back.cols.defs[back.cols.level_b[leaf] + lv]:
                raise Error(path)
            if t.cols.reps[t.cols.level_b[leaf] + lv] != back.cols.reps[back.cols.level_b[leaf] + lv]:
                raise Error(path)
            lv += 1
        var physical = t.foot.schema.physical[t.cols.schema_i[leaf]]
        if physical == 4 or physical == 5:
            var i = 0
            while i < t.cols.val_n[leaf]:
                if t.cols.bits[t.cols.val_b[leaf] + i] != back.cols.bits[back.cols.val_b[leaf] + i]:
                    raise Error(path)
                i += 1
        elif physical == 6 or physical == 7 or physical == 3:
            if t.cols.val_n[leaf] > 0:
                var a_end = t.cols.ends[t.cols.val_b[leaf] + t.cols.val_n[leaf] - 1]
                var b_end = back.cols.ends[back.cols.val_b[leaf] + back.cols.val_n[leaf] - 1]
                var a0 = t.cols.byte_b[leaf]
                var b0 = back.cols.byte_b[leaf]
                if a_end - a0 != b_end - b0:
                    raise Error(path)
                var bi = 0
                while bi < t.cols.val_n[leaf]:
                    var ae = t.cols.ends[t.cols.val_b[leaf] + bi] - a0
                    var be = back.cols.ends[back.cols.val_b[leaf] + bi] - b0
                    if ae != be:
                        raise Error(path)
                    bi += 1
                var k = 0
                while k < a_end - a0:
                    if t.cols.raw[a0 + k] != back.cols.raw[b0 + k]:
                        raise Error(path)
                    k += 1
        else:
            same_i(t.cols.val_b[leaf], t.cols.val_n[leaf], back.cols.val_b[leaf], back.cols.val_n[leaf], t.cols.i64s, back.cols.i64s)
        leaf += 1
def main() raises:
    round_one("testdata/opt_i32.parquet")
    round_one("testdata/required_i64.parquet")
    round_one("testdata/strings.parquet")
    round_one("testdata/bools.parquet")
    round_one("testdata/floats.parquet")
    round_one("testdata/list_i32.parquet")
    round_one("testdata/struct.parquet")
    round_one("testdata/multi_rg.parquet")
    round_one("testdata/dict_str.parquet")
    print("ok")
