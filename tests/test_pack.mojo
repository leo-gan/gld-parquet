from std.collections import List, Span

from runtime.pack import delta_int_decode, delta_int_encode, rle_decode, rle_encode
from runtime.thrift import TOut, TRead, T_I32, T_STRUCT


def main() raises:
    var vals = List[Int]()
    vals.append(1)
    vals.append(2)
    vals.append(3)
    vals.append(4)
    vals.append(5)
    var enc = rle_encode(vals, 5, 3)
    var i = 0
    var back = rle_decode(enc, i, len(enc), 3, 5)
    if len(back) != 5 or back[0] != 1 or back[4] != 5:
        raise Error("rle")
    var d = delta_int_encode(vals, 5, 32)
    var got = delta_int_decode(d, 0, len(d), 32)
    if len(got.vals) != 5 or got.vals[1] != 2 or got.vals[4] != 5:
        raise Error("delta up")
    var down = List[Int]()
    down.append(7)
    down.append(5)
    down.append(3)
    down.append(1)
    down.append(2)
    down.append(3)
    down.append(4)
    down.append(5)
    var d2 = delta_int_encode(down, 8, 32)
    var g2 = delta_int_decode(d2, 0, len(d2), 32)
    if len(g2.vals) != 8 or g2.vals[0] != 7 or g2.vals[3] != 1 or g2.vals[7] != 5:
        raise Error("delta down")
    var w = TOut()
    var prev = w.begin(1)
    w.i32(1, 7)
    w.text(2, "ab")
    w.end(prev)
    var rd = TRead(Span(w.b))
    if rd.next() == 0 or rd.fid != 1 or rd.typ != T_STRUCT:
        raise Error("thrift field")
    var saved = rd.enter()
    if rd.next() == 0 or rd.read_i32() != 7:
        raise Error("thrift i32")
    if rd.next() == 0 or rd.read_text() != "ab":
        raise Error("thrift text")
    if rd.next() != 0:
        raise Error("thrift stop")
    rd.leave(saved)
    _ = T_I32
    print("ok")
