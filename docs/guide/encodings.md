# Package 10 — Encodings

Package 10 defines how component values are serialized on the wire. Four encoding methods are available, selectable via the `AnyEncoding` union.

## AnyEncoding

The discriminated union over all encoding methods:

| Variant | Use case |
|---------|----------|
| `TextEncoding` | CSV-like delimited text |
| `JSONEncoding` | JSON arrays/objects (new in 3.0) |
| `XMLEncoding` | XML elements |
| `BinaryEncoding` | Raw or base64 binary with explicit layout |

## TextEncoding

A CSV-like delimited text encoding. Values are converted to strings and separated by configurable delimiters.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractEncoding | Inherited id |
| `collapseWhiteSpaces` | bool | Collapse runs of whitespace to a single space |
| `decimalSeparator` | string | Character for decimal point (default `"."`) |
| `tokenSeparator` | string | Field delimiter within a record (required) |
| `blockSeparator` | string | Record delimiter (required) |

### Example

With `tokenSeparator=","` and `blockSeparator="\n"`, a DataRecord with three Quantity fields encodes as:

```
23.5,1013.25,65.0
24.1,1012.80,63.5
```

## JSONEncoding

JSON-based encoding, new in SWE Common 3.0. Gives you a choice between object-style (field names as keys) and array-style (positional values) encoding.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractEncoding | Inherited id |
| `recordsAsArrays` | bool | Encode DataRecord fields as JSON arrays (default false) |
| `vectorsAsArrays` | bool | Encode Vector coordinates as JSON arrays (default false) |

When `recordsAsArrays` is false (the default), a DataRecord serializes as:

```json
{"temperature": 23.5, "humidity": 65.0, "timestamp": "2025-06-15T14:30:00Z"}
```

When true, the same record becomes:

```json
[23.5, 65.0, "2025-06-15T14:30:00Z"]
```

## XMLEncoding

XML element-based encoding.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractEncoding | Inherited id |
| `namespace` | string | XML namespace URI |

## BinaryEncoding

Raw or base64 binary encoding with explicit member layout. This is the most compact encoding and gives you full control over byte order, data types, and padding.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractEncoding | Inherited id |
| `byteOrder` | ByteOrder | `bigEndian` or `littleEndian` (required) |
| `byteEncoding` | ByteEncoding | `raw` or `base64` (required) |
| `byteLength` | uint64 | Total stream length if known |
| `members` | list of BinaryMember | Layout of each member (required, min 1) |

### BinaryMember

Each member in the binary layout is either a `BinaryComponent` (single scalar) or a `BinaryBlock` (group of values with possible compression/encryption).

**BinaryComponent** — parameters for a single scalar value:

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSWE | Inherited id |
| `encryption` | string | URI — encryption method |
| `significantBits` | uint32 | Number of significant bits |
| `bitLength` | uint32 | Bit length on wire |
| `byteLength` | uint32 | Byte length on wire |
| `dataType` | string | URI — data type (required) |
| `ref` | string | Path reference to the component (required) |

**BinaryBlock** — parameters for a block of values:

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSWE | Inherited id |
| `compression` | string | URI — compression method |
| `encryption` | string | URI — encryption method |
| `paddingBytesBefore` | uint32 | Leading padding |
| `paddingBytesAfter` | uint32 | Trailing padding |
| `byteLength` | uint32 | Block size on wire |
| `ref` | string | Path reference (required) |

### ByteOrder and ByteEncoding

=== "Cap'n Proto"

    ```capnp
    enum ByteOrder    { bigEndian @0; littleEndian @1; }
    enum ByteEncoding { raw @0; base64 @1; }
    ```

=== "FlatBuffers"

    ```fbs
    enum ByteOrder : byte    { BigEndian = 0, LittleEndian }
    enum ByteEncoding : byte { Raw = 0, Base64 }
    ```

=== "Protocol Buffers"

    ```protobuf
    enum ByteOrder {
      BYTE_ORDER_UNSPECIFIED = 0;
      BYTE_ORDER_BIG_ENDIAN = 1;
      BYTE_ORDER_LITTLE_ENDIAN = 2;
    }
    enum ByteEncoding {
      BYTE_ENCODING_UNSPECIFIED = 0;
      BYTE_ENCODING_RAW = 1;
      BYTE_ENCODING_BASE64 = 2;
    }
    ```

## Choosing an encoding

| Encoding | Best for |
|----------|----------|
| TextEncoding | Human-readable output, CSV interoperability, debugging |
| JSONEncoding | Web APIs, JavaScript consumers, REST services |
| XMLEncoding | OGC XML ecosystem interoperability |
| BinaryEncoding | High-throughput sensor streams, embedded systems, minimal bandwidth |
