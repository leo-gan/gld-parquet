from wire.decode import decode_table


def main() raises:
    var raw = open("testdata/opt_i32.parquet", "r").read_bytes()
    var t = decode_table(raw)
    if t.nrows != 3 or t.cols.val_n[0] != 2 or t.cols.level_n[0] != 3:
        raise Error("opt shape")
    if t.cols.i64s[t.cols.val_b[0]] != 1 or t.cols.i64s[t.cols.val_b[0] + 1] != 3:
        raise Error("opt values")
    if t.cols.defs[t.cols.level_b[0] + 1] != 0:
        raise Error("null def")
    var req = open("testdata/required_i64.parquet", "r").read_bytes()
    var r = decode_table(req)
    if r.cols.val_n[0] != 3 or r.cols.i64s[0] != 10 or r.cols.i64s[2] != 0:
        raise Error("required")
    var sn = open("testdata/snappy_i32.parquet", "r").read_bytes()
    var s = decode_table(sn)
    if s.cols.val_n[0] != 100 or s.cols.i64s[0] != 1 or s.cols.i64s[99] != 5:
        raise Error("snappy")
    var gz = open("testdata/gzip_i32.parquet", "r").read_bytes()
    var g = decode_table(gz)
    if g.cols.val_n[0] != 50 or g.cols.i64s[49] != 49:
        raise Error("gzip")
    var zs = open("testdata/zstd_i32.parquet", "r").read_bytes()
    var z = decode_table(zs)
    if z.cols.val_n[0] != 40 or z.cols.i64s[39] != 39:
        raise Error("zstd")
    var lz = open("testdata/lz4_i32.parquet", "r").read_bytes()
    var l = decode_table(lz)
    if l.cols.val_n[0] != 40 or l.cols.i64s[7] != 7:
        raise Error("lz4")
    var st = open("testdata/strings.parquet", "r").read_bytes()
    var ss = decode_table(st)
    if ss.cols.val_n[0] != 2 or ss.cols.ends[0] != 2:
        raise Error("strings")
    var ds = open("testdata/dict_str.parquet", "r").read_bytes()
    var d = decode_table(ds)
    if d.cols.val_n[0] != 5:
        raise Error("dict count")
    var bo = open("testdata/bools.parquet", "r").read_bytes()
    var b = decode_table(bo)
    if b.cols.val_n[0] != 3 or b.cols.i64s[0] != 1 or b.cols.i64s[1] != 0 or b.cols.i64s[2] != 1:
        raise Error("bools")
    var fl = open("testdata/floats.parquet", "r").read_bytes()
    var f = decode_table(fl)
    if f.cols.val_n[0] != 3:
        raise Error("floats")
    if f.cols.bits[1] != 0x8000000000000000:
        raise Error("negzero")
    var rg = open("testdata/multi_rg.parquet", "r").read_bytes()
    var m = decode_table(rg)
    if m.cols.val_n[0] != 10 or m.cols.i64s[0] != 0 or m.cols.i64s[9] != 9:
        raise Error("row groups")
    var v2 = open("testdata/v2.parquet", "r").read_bytes()
    var v = decode_table(v2)
    if v.cols.val_n[0] != 3 or v.cols.i64s[0] != 1 or v.cols.i64s[2] != 3:
        raise Error("v2")
    var ls = open("testdata/list_i32.parquet", "r").read_bytes()
    var li = decode_table(ls)
    if li.foot.schema.nleaves != 1 or li.cols.level_n[0] < 4:
        raise Error("list")
    var su = open("testdata/struct.parquet", "r").read_bytes()
    var su_t = decode_table(su)
    if su_t.foot.schema.nleaves != 2:
        raise Error("struct")
    var bs = open("testdata/bss.parquet", "r").read_bytes()
    var bf = decode_table(bs)
    if bf.cols.val_n[0] != 3:
        raise Error("bss")
    var dec = open("testdata/decimal.parquet", "r").read_bytes()
    var dd = decode_table(dec)
    if dd.cols.val_n[0] != 2 or dd.foot.schema.logical[dd.cols.schema_i[0]] != 5:
        raise Error("decimal")
    var ts = open("testdata/ts.parquet", "r").read_bytes()
    var tt = decode_table(ts)
    if tt.cols.val_n[0] != 1 or tt.foot.schema.logical[tt.cols.schema_i[0]] != 8:
        raise Error("timestamp")
    var dt = open("testdata/date.parquet", "r").read_bytes()
    var dtd = decode_table(dt)
    if dtd.cols.val_n[0] != 2:
        raise Error("date")
    var mp = open("testdata/map.parquet", "r").read_bytes()
    var md = decode_table(mp)
    if md.foot.schema.nleaves < 2:
        raise Error("map")
    print("ok")
