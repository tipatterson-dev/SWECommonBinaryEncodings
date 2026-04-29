# Package 8 — Arrays & Streams

Package 8 defines block-oriented types for homogeneous collections and streaming data: `DataArray`, `Matrix`, and `DataStream`.

## DataArray

An ISO-11404 Array — a homogeneous collection of identically-typed elements. The element structure is described once, then repeated `elementCount` times in the encoded values.

| Field | Type | Description |
|-------|------|-------------|
| `dataComponent` | AbstractDataComponent | Inherited metadata |
| `elementCount` | ElementCountOrRef | Number of elements (inline or by reference) |
| `elementType` | NamedComponent | Structure of each element |
| `encoding` | AnyEncoding | How values are serialized |
| `values` | EncodedValues | The encoded payload (inline or external link) |

### ElementCount

The array size can be a fixed literal value or a reference to another component whose value supplies the count at runtime:

=== "Cap'n Proto"

    ```capnp
    struct ElementCountOrRef {
      union {
        inline @0 :ElementCount;
        ref    @1 :BT.AssociationAttributeGroup;
      }
    }
    ```

=== "Protocol Buffers"

    ```protobuf
    message ElementCountOrRef {
      oneof kind {
        ElementCount inline = 1;
        AssociationAttributeGroup ref = 2;
      }
    }
    ```

### EncodedValues

The payload can be provided inline as raw bytes or linked externally:

| Variant | Description |
|---------|-------------|
| `inlineArray` / `inline_data` | Opaque byte payload encoded according to the `encoding` field |
| `ref` | XLink association pointing to an external resource |

### Example: spectral data

A 256-band spectral radiance array:

```
DataArray "Spectrum"
  elementCount: 256
  elementType: "band" → Quantity (uom: "W/m2/sr/nm")
  encoding: BinaryEncoding (littleEndian, raw)
  values: <1024 bytes of packed float32>
```

## Matrix

A specialization of DataArray that carries a reference frame. Used for rotation matrices, affine transforms, covariance matrices, and similar grid-like data with spatial semantics.

| Field | Type | Description |
|-------|------|-------------|
| `dataComponent` | AbstractDataComponent | Inherited metadata |
| `elementCount` | ElementCountOrRef | Size (total cells, or row count) |
| `elementType` | NamedComponent | Cell structure |
| `encoding` | AnyEncoding | Serialization method |
| `values` | EncodedValues | Encoded payload |
| `referenceFrame` | string | URI-reference to a CRS |
| `localFrame` | string | URI-reference — frame defined by this matrix |

The only difference from `DataArray` is the two additional frame fields. The encoding and values mechanics are identical.

## DataStream

A descriptor for a stream of identically-structured observation records. Unlike all other composite types, `DataStream` extends `AbstractSWEIdentifiable` rather than `AbstractDataComponent` — it describes a stream, not a single data component.

| Field | Type | Description |
|-------|------|-------------|
| `identifiable` | AbstractSWEIdentifiable | Id, label, description |
| `elementType` | NamedComponent | Structure of each record (required) |
| `encoding` | AnyEncoding | How records are serialized (required) |
| `values` | AssociationAttributeGroup | Out-of-band link to the stream data |

!!! warning "Values are always external"
    Unlike `DataArray`, a `DataStream`'s values are never inline — they're always an external link via `AssociationAttributeGroup`. The stream data lives at a URL, in a file, or behind a service endpoint.

### Example: real-time weather feed

```
DataStream "WeatherFeed"
  elementType: "observation" → DataRecord
    ├── station_id: Text
    ├── temperature: Quantity (uom: "Cel")
    ├── pressure: Quantity (uom: "hPa")
    └── timestamp: Time (ISO-8601)
  encoding: JSONEncoding (recordsAsArrays: false)
  values: href="wss://api.example.com/weather/stream"
```

## Root message

Both FlatBuffers and Protocol Buffers define a root message type that wraps either an `AnyComponent` or a `DataStream`:

=== "FlatBuffers"

    ```fbs
    union SweCommonRoot { AnyComponentWrapper, DataStream }
    table SweCommonMessage { root:SweCommonRoot; }
    root_type SweCommonMessage;
    file_identifier "SWEC";
    file_extension "swe";
    ```

=== "Protocol Buffers"

    ```protobuf
    message SweCommonMessage {
      oneof root {
        AnyComponent component = 1;
        DataStream data_stream = 2;
      }
    }
    ```

Cap'n Proto does not declare a root type — callers wrap the top-level struct themselves using `initRoot<T>()`.
