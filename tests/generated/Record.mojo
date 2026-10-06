from std.collections import List, Span

from runtime.model import Cols, Schema, WriteOpts
from wire.decode import Table, decode_table
from wire.encode import encode_table


struct Record:
    var id: Int
    var name: String

    def __init__(out self):
        self.id = 0
        self.name = ""

    def encoded_len(self) raises -> Int:
        var raw = self.encode_bytes()
        return len(raw)

    def encode_to(self, mut buf: List[Byte]) raises:
        var raw = self.encode_bytes()
        var i = 0
        while i < len(raw):
            buf.append(raw[i])
            i += 1

    def encode_bytes(self) raises -> List[Byte]:
        var schema = Schema()
        schema.add("schema", -1, -1, 0, 2, 0)
        schema.add("id", 2, 0, 0, 0, 10)
        schema.bit_width[1] = 64
        schema.is_signed[1] = 1
        schema.add("name", 6, 1, 0, 0, 1)
        schema.finish()
        var cols = Cols()
        cols.begin(1, 2)
        cols.add_i64(self.id)
        cols.begin(2, 6)
        cols.add_level(1, 0)
        var raw_1 = List[Byte]()
        var bytes_1 = self.name.as_bytes()
        var k_1 = 0
        while k_1 < len(bytes_1):
            raw_1.append(bytes_1[k_1])
            k_1 += 1
        cols.add_bytes(raw_1)
        var table = Table()
        table.nrows = 1
        table.cols = cols^
        table.foot.schema = schema^
        var opts = WriteOpts()
        return encode_table(table, opts)

    @staticmethod
    def decode_from[origin: ImmOrigin](raw: Span[Byte, origin]) raises -> Self:
        var table = decode_table(raw)
        var out = Self()
        if table.cols.val_n[0] > 0:
            out.id = table.cols.i64s[table.cols.val_b[0]]
        return out^
