# OGC SWE Common Data Model 3.0 — Cap'n Proto Schema — Encodings
# Package 10: text, JSON, XML, and binary block encoding descriptors.
# Standard: OGC 24-014  (https://docs.ogc.org/is/24-014/24-014.html)

@0xfb54f15751bee9e4;

using BT = import "basic_types.capnp";


# ═══════════════════════════════════════════════════════════════════════════
# Package 10 — Encodings
# ═══════════════════════════════════════════════════════════════════════════

struct AbstractEncoding {
  base @0 :BT.AbstractSWE;
}

struct TextEncoding {
  # CSV-like delimited text encoding.
  base                @0 :AbstractEncoding;
  collapseWhiteSpaces @1 :Bool;
  decimalSeparator    @2 :Text;   # default "."
  tokenSeparator      @3 :Text;   # required
  blockSeparator      @4 :Text;   # required
}

struct JSONEncoding {
  # JSON array/object encoding (new in SWE Common 3.0).
  base            @0 :AbstractEncoding;
  recordsAsArrays @1 :Bool;   # default false
  vectorsAsArrays @2 :Bool;   # default false
}

struct XMLEncoding {
  # XML element encoding.
  base      @0 :AbstractEncoding;
  namespace @1 :Text;   # URI
}

enum ByteOrder {
  bigEndian    @0;
  littleEndian @1;
}

enum ByteEncoding {
  raw    @0;
  base64 @1;
}

struct BinaryComponent {
  # Encoding parameters for a single scalar value in a binary stream.
  base            @0 :BT.AbstractSWE;
  encryption      @1 :Text;    # URI
  significantBits @2 :UInt32;
  bitLength       @3 :UInt32;
  byteLength      @4 :UInt32;
  dataType        @5 :Text;    # URI — required
  ref             @6 :Text;    # path reference — required
}

struct BinaryBlock {
  # Encoding parameters for a block of values (compression, encryption).
  base               @0 :BT.AbstractSWE;
  compression        @1 :Text;    # URI
  encryption         @2 :Text;    # URI
  paddingBytesBefore @3 :UInt32;
  paddingBytesAfter  @4 :UInt32;
  byteLength         @5 :UInt32;
  ref                @6 :Text;    # path reference — required
}

struct BinaryMember {
  union {
    component @0 :BinaryComponent;
    block     @1 :BinaryBlock;
  }
}

struct BinaryEncoding {
  # Raw / base64 binary encoding with explicit member layout.
  base         @0 :AbstractEncoding;
  byteOrder    @1 :ByteOrder;           # required
  byteEncoding @2 :ByteEncoding;        # required
  byteLength   @3 :UInt64;             # total stream length if known
  members      @4 :List(BinaryMember); # required, minItems 1
}

struct AnyEncoding {
  # Discriminated union over all encoding methods.
  union {
    textEncoding   @0 :TextEncoding;
    jsonEncoding   @1 :JSONEncoding;
    xmlEncoding    @2 :XMLEncoding;
    binaryEncoding @3 :BinaryEncoding;
  }
}