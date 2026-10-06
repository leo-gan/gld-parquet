from wire.footer import read_footer


def main() raises:
    var raw = open("testdata/opt_i32.parquet", "r").read_bytes()
    var foot = read_footer(raw)
    if foot.nrows != 3 or foot.schema.nleaves != 1:
        raise Error("shape")
    if foot.schema.name[1] != "a" or foot.schema.physical[1] != 1 or foot.schema.rep[1] != 1:
        raise Error("col")
    if foot.schema.max_def[1] != 1:
        raise Error("def")
    if len(foot.col_type) != 1 or foot.col_values[0] != 3 or foot.col_codec[0] != 0:
        raise Error("chunk")
    var listed = open("testdata/list_i32.parquet", "r").read_bytes()
    var lf = read_footer(listed)
    if lf.schema.nleaves != 1 or lf.nrows != 4:
        raise Error("list")
    if lf.schema.max_rep[lf.schema.nleaves] < 0:
        raise Error("rep")
    var s = open("testdata/struct.parquet", "r").read_bytes()
    var sf = read_footer(s)
    if sf.schema.nleaves != 2:
        raise Error("struct leaves")
    print("ok", foot.created_by)
