"""Small value types shared by the native Reta Mojo port."""

@fieldwise_init
struct IntPair(Copyable, Equatable, Writable):
    """A copyable integer pair used instead of dynamically typed Python tuples."""

    var first: Int
    var second: Int

    def __eq__(self, other: Self) -> Bool:
        return self.first == other.first and self.second == other.second

    def write_to[W: Writer](self, mut writer: W):
        writer.write("(", self.first, ", ", self.second, ")")


@fieldwise_init
struct StringIntPair(Copyable, Writable):
    var text: String
    var value: Int

    def write_to[W: Writer](self, mut writer: W):
        writer.write("(", self.text, ", ", self.value, ")")
