from std.collections import List, Span

from runtime.error import DecodeError


comptime MAX_BYTES = 268435456


def buf_need(have: Int, want: Int, at: Int) raises DecodeError:
    if want < 0 or at < 0 or at > have or want > have - at:
        raise DecodeError(DecodeError.KIND_EOF, at)
    if want > MAX_BYTES:
        raise DecodeError(DecodeError.KIND_RANGE, at)


def put_u8(mut b: List[Byte], v: Int):
    b.append(Byte(v & 255))


def put_u16(mut b: List[Byte], v: Int):
    put_u8(b, v)
    put_u8(b, v >> 8)


def put_u32(mut b: List[Byte], v: Int):
    put_u8(b, v)
    put_u8(b, v >> 8)
    put_u8(b, v >> 16)
    put_u8(b, v >> 24)


def put_u64(mut b: List[Byte], v: UInt64):
    var x = v
    var i = 0
    while i < 8:
        b.append(Byte(Int(x & 0xFF)))
        x = x >> UInt64(8)
        i += 1


def put_i32(mut b: List[Byte], v: Int):
    var u = v
    if u < 0:
        u = u + 4294967296
    put_u32(b, u)


def put_i64(mut b: List[Byte], v: Int):
    put_u64(b, UInt64(v))


def extend_span[origin: ImmOrigin](mut dst: List[Byte], raw: Span[Byte, origin]):
    var base = len(dst)
    var n = len(raw)
    if n == 0:
        return
    dst.resize(base + n, Byte(0))
    var i = 0
    while i < n:
        dst[base + i] = raw[i]
        i += 1


def extend_list(mut dst: List[Byte], raw: List[Byte]):
    extend_span(dst, Span(raw))


def u8_at[origin: ImmOrigin](raw: Span[Byte, origin], i: Int) raises DecodeError -> Int:
    buf_need(len(raw), 1, i)
    return Int(raw[i])


def u32_at[origin: ImmOrigin](raw: Span[Byte, origin], i: Int) raises DecodeError -> Int:
    buf_need(len(raw), 4, i)
    return Int(raw[i]) | (Int(raw[i + 1]) << 8) | (Int(raw[i + 2]) << 16) | (Int(raw[i + 3]) << 24)


def u64_at[origin: ImmOrigin](raw: Span[Byte, origin], i: Int) raises DecodeError -> UInt64:
    buf_need(len(raw), 8, i)
    var x = UInt64(0)
    var k = 7
    while k >= 0:
        x = (x << UInt64(8)) | UInt64(Int(raw[i + k]))
        k -= 1
    return x


def i32_at[origin: ImmOrigin](raw: Span[Byte, origin], i: Int) raises DecodeError -> Int:
    var u = u32_at(raw, i)
    if u >= 2147483648:
        return u - 4294967296
    return u


def i64_of(u: UInt64) -> Int:
    if u > 9223372036854775807:
        return Int(u - 9223372036854775808) - 9223372036854775807 - 1
    return Int(u)


def i64_at[origin: ImmOrigin](raw: Span[Byte, origin], i: Int) raises DecodeError -> Int:
    return i64_of(u64_at(raw, i))


def list_u32(data: List[Byte], i: Int) raises DecodeError -> Int:
    return u32_at(Span(data), i)


def list_i32(data: List[Byte], i: Int) raises DecodeError -> Int:
    return i32_at(Span(data), i)


def list_i64(data: List[Byte], i: Int) raises DecodeError -> Int:
    return i64_at(Span(data), i)


def slice_list(data: List[Byte], off: Int, n: Int) -> List[Byte]:
    var out = List[Byte]()
    if n <= 0:
        return out^
    out.resize(n, Byte(0))
    var i = 0
    while i < n:
        out[i] = data[off + i]
        i += 1
    return out^


def crc32_bytes(data: List[Byte], off: Int, n: Int) -> Int:
    var crc = 0xFFFFFFFF
    var i = 0
    while i < n:
        crc = crc ^ Int(data[off + i])
        var b = 0
        while b < 8:
            if (crc & 1) != 0:
                crc = (crc >> 1) ^ 0xEDB88320
            else:
                crc = crc >> 1
            b += 1
        i += 1
    crc = crc ^ 0xFFFFFFFF
    if crc >= 2147483648:
        return crc - 4294967296
    return crc


def utf8_ok[origin: ImmOrigin](raw: Span[Byte, origin]) -> Bool:
    var i = 0
    var n = len(raw)
    while i < n:
        var c = Int(raw[i])
        if c < 0x80:
            i += 1
        elif c < 0xC2 or c > 0xF4:
            return False
        else:
            var need = 1
            var minv = 0x80
            var maxv = 0xBF
            if c >= 0xE0:
                need = 2
            if c >= 0xF0:
                need = 3
            if i + need >= n:
                return False
            if c == 0xE0:
                minv = 0xA0
            if c == 0xED:
                maxv = 0x9F
            if c == 0xF0:
                minv = 0x90
            if c == 0xF4:
                maxv = 0x8F
            var k = 1
            while k <= need:
                var cc = Int(raw[i + k])
                var lo = 0x80
                var hi = 0xBF
                if k == 1:
                    lo = minv
                    hi = maxv
                if cc < lo or cc > hi:
                    return False
                k += 1
            i += need + 1
    return True


def string_from[origin: ImmOrigin](raw: Span[Byte, origin], at: Int) raises DecodeError -> String:
    if not utf8_ok(raw):
        raise DecodeError(DecodeError.KIND_UTF8, at)
    return String(unsafe_from_utf8=raw)


def bytes_of(text: String) -> List[Byte]:
    var out = List[Byte]()
    var raw = text.as_bytes()
    extend_span(out, raw)
    return out^
