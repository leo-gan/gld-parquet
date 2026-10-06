from std.collections import List

from compress.gzip import gzip_compress, gzip_decompress
from compress.lz4raw import lz4_raw_compress, lz4_raw_decompress
from compress.snappy import snappy_compress, snappy_decompress
from compress.zstd import zstd_compress, zstd_decompress


def hex_of(text: String) -> List[Byte]:
    var raw = text.as_bytes()
    var out = List[Byte]()
    var i = 0
    while i + 1 < len(raw):
        var c0 = Int(raw[i])
        var c1 = Int(raw[i + 1])
        var n0 = 0
        var n1 = 0
        if c0 >= 48 and c0 <= 57:
            n0 = c0 - 48
        else:
            n0 = c0 - 65 + 10
        if c1 >= 48 and c1 <= 57:
            n1 = c1 - 48
        else:
            n1 = c1 - 65 + 10
        out.append(Byte((n0 << 4) | n1))
        i += 2
    return out^


def sample(k: Int) -> List[Byte]:
    var out = List[Byte]()
    if k == 0:
        return out^
    if k == 1:
        out.append(Byte(0))
        return out^
    if k == 2:
        out.append(Byte(97))
        return out^
    if k == 3:
        var s = "hello".as_bytes()
        var i = 0
        while i < len(s):
            out.append(s[i])
            i += 1
        return out^
    if k == 4:
        var i = 0
        while i < 100:
            out.append(Byte(65))
            i += 1
        return out^
    var i = 0
    while i < 20:
        var s = "hello hello hello world".as_bytes()
        var j = 0
        while j < len(s):
            out.append(s[j])
            j += 1
        i += 1
    return out^


def same(a: List[Byte], b: List[Byte]) -> Bool:
    if len(a) != len(b):
        return False
    var i = 0
    while i < len(a):
        if a[i] != b[i]:
            return False
        i += 1
    return True


def check_pair(kind: Int, raw: List[Byte]) raises:
    var comp = List[Byte]()
    var back = List[Byte]()
    if kind == 0:
        comp = snappy_compress(raw)
        back = snappy_decompress(comp)
    elif kind == 1:
        comp = gzip_compress(raw)
        back = gzip_decompress(comp)
    elif kind == 2:
        comp = lz4_raw_compress(raw)
        back = lz4_raw_decompress(comp)
    else:
        comp = zstd_compress(raw)
        back = zstd_decompress(comp)
    if not same(raw, back):
        raise Error("round trip")


def check_gold(kind: Int, raw: List[Byte], gold: String) raises:
    var comp = hex_of(gold)
    var back = List[Byte]()
    if kind == 0:
        back = snappy_decompress(comp)
    elif kind == 1:
        back = gzip_decompress(comp)
    elif kind == 2:
        back = lz4_raw_decompress(comp)
    else:
        back = zstd_decompress(comp)
    if not same(raw, back):
        raise Error("golden")


def main() raises:
    var k = 0
    while k < 6:
        var raw = sample(k)
        var c = 0
        while c < 4:
            check_pair(c, raw)
            c += 1
        k += 1
    check_gold(0, sample(0), "00")
    check_gold(0, sample(1), "010000")
    check_gold(0, sample(2), "010061")
    check_gold(0, sample(3), "051068656C6C6F")
    check_gold(0, sample(4), "640041FE01008A0100")
    check_gold(1, sample(0), "1F8B080000000000020303000000000000000000")
    check_gold(1, sample(1), "1F8B08000000000002036300008DEF02D201000000")
    check_gold(1, sample(2), "1F8B08000000000002034B040043BEB7E801000000")
    check_gold(1, sample(3), "1F8B0800000000000203CB48CDC9C9070086A6103605000000")
    check_gold(1, sample(4), "1F8B08000000000002037374A43D00008DBC979564000000")
    check_gold(2, sample(0), "00")
    check_gold(2, sample(1), "1000")
    check_gold(2, sample(2), "1061")
    check_gold(2, sample(3), "5068656C6C6F")
    check_gold(2, sample(4), "1F4101004B504141414141")
    check_gold(3, sample(0), "28B52FFD2000010000")
    check_gold(3, sample(1), "28B52FFD200109000000")
    check_gold(3, sample(3), "28B52FFD200529000068656C6C6F")
    check_gold(3, sample(4), "28B52FFD206445000010414101003F012C")
    print("ok")
