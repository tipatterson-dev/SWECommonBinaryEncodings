# Encoding Comparison

This page provides side-by-side comparisons of how each OGC concept maps across Cap'n Proto, FlatBuffers, and Protocol Buffers.

## Format overview

| Feature | Cap'n Proto | FlatBuffers | Protocol Buffers |
|---------|------------|-------------|------------------|
| **Schema file** | `.capnp` | `.fbs` | `.proto` |
| **Wire format** | Pointer-based | Offset-based | Tag-length-value |
| **Zero-copy read** | Yes | Yes | No (requires parse) |
| **Schema evolution** | Add fields with new ordinals | Add fields at table end | Add fields with new tags |
| **Namespace** | File-level | `namespace ogc.swecommon` | `package ogc.swecommon` |
| **Root type** | None (caller picks) | `SweCommonMessage` | `SweCommonMessage` |

## Inheritance mapping

All three formats lack class inheritance. The solution is the same everywhere — embed the abstract base as a named field:

=== "Cap'n Proto"

    ```capnp
    struct Quantity {
      base @0 :BT.AbstractSimpleComponent;   # ← embedded
      uom  @1 :BT.UnitReference;
      # ...
    }
    ```

=== "FlatBuffers"

    ```fbs
    table Quantity {
      base:AbstractSimpleComponent;           // ← embedded
      uom:UnitReference (required);
      // ...
    }
    ```

=== "Protocol Buffers"

    ```protobuf
    message Quantity {
      AbstractSimpleComponent base = 1;       // ← embedded
      UnitReference uom = 2;
      // ...
    }
    ```

## Polymorphism: unions

=== "Cap'n Proto"

    Uses unnamed unions inside a wrapper struct:

    ```capnp
    struct AnyComponent {
      union {
        boolean       @0  :SC.Boolean;
        count         @1  :SC.Count;
        quantity      @2  :SC.Quantity;
        # ... 16 total variants
      }
    }
    ```

=== "FlatBuffers"

    Uses native `union` types:

    ```fbs
    union AnyComponent {
      Boolean, Count, Quantity, Time, Category, Text,
      CountRange, QuantityRange, TimeRange, CategoryRange,
      DataRecord, Vector, DataArray, Matrix, DataChoice,
      Geometry
    }
    ```

=== "Protocol Buffers"

    Uses `oneof` inside a message:

    ```protobuf
    message AnyComponent {
      oneof component {
        Boolean boolean_component = 1;
        Count count_component = 2;
        Quantity quantity_component = 3;
        // ... 16 total fields
      }
    }
    ```

## Key differences by concept

### NumberOrSpecial

| Format | Approach |
|--------|----------|
| Cap'n Proto | Unnamed union with `Void` sentinels for NaN/±Inf |
| FlatBuffers | Enum discriminator (`NumberOrSpecialKind`) + separate `number` field |
| Protocol Buffers | `oneof` with `bool` sentinels for NaN/±Inf |

**Why they differ:** Cap'n Proto unions can mix scalars and `Void` naturally. FlatBuffers tables can't have inline unions of scalar/string combinations, so an enum discriminator is used instead. Protobuf `oneof` requires message or scalar types — `bool` stands in for the sentinel flags.

### AllowedTokens

| Format | Approach |
|--------|----------|
| Cap'n Proto | Unnamed union: `List(Text)` or `Text` pattern |
| FlatBuffers | Enum discriminator (`AllowedTokensKind`) + separate fields |
| Protocol Buffers | Nested `TokenList` message wrapping `repeated string` inside `oneof` |

**Why they differ:** Proto3 `oneof` cannot contain `repeated` fields directly. FlatBuffers unions cannot contain vector types. Only Cap'n Proto can union a list with a scalar directly.

### ComponentOrRef (nested unions)

| Format | Approach |
|--------|----------|
| Cap'n Proto | Direct union of `AnyComponent` and `AssociationAttributeGroup` |
| FlatBuffers | `AnyComponentWrapper` table wraps `AnyComponent` union first |
| Protocol Buffers | Direct `oneof` with `AnyComponent` message and `AssociationAttributeGroup` |

**Why they differ:** FlatBuffers unions cannot directly contain other unions — the `AnyComponentWrapper` table exists solely as a workaround.

### Field naming

| Concept | Cap'n Proto | FlatBuffers | Protocol Buffers |
|---------|------------|-------------|------------------|
| OGC `optional` field | `optional` | `is_optional` | `is_optional` |
| Enum values | camelCase | PascalCase | `SCREAMING_SNAKE_CASE` |
| Field names | camelCase | snake_case | snake_case |
| Struct/table names | PascalCase | PascalCase | PascalCase |

### Root type

| Format | Root type | Details |
|--------|-----------|---------|
| Cap'n Proto | None | Caller uses `initRoot<T>()` directly |
| FlatBuffers | `SweCommonMessage` | File ID `"SWEC"`, extension `.swe` |
| Protocol Buffers | `SweCommonMessage` | `oneof root { AnyComponent, DataStream }` |

### Enum style

=== "Cap'n Proto"

    ```capnp
    enum GeometryType {
      point           @0;
      multiPoint      @1;
      lineString      @2;
    }
    ```

=== "FlatBuffers"

    ```fbs
    enum GeometryType : byte {
      Point = 0,
      MultiPoint,
      LineString
    }
    ```

=== "Protocol Buffers"

    ```protobuf
    enum GeometryType {
      GEOMETRY_TYPE_UNSPECIFIED = 0;
      GEOMETRY_TYPE_POINT = 1;
      GEOMETRY_TYPE_MULTI_POINT = 2;
      GEOMETRY_TYPE_LINE_STRING = 3;
    }
    ```

## Performance characteristics

| Aspect | Cap'n Proto | FlatBuffers | Protocol Buffers |
|--------|------------|-------------|------------------|
| Serialization | Very fast (pointer copy) | Fast (offset table) | Moderate (encoding step) |
| Deserialization | Zero-copy | Zero-copy | Full parse required |
| Wire size | Larger (8-byte aligned) | Medium | Smallest (varint encoding) |
| Random access | Yes | Yes | No (sequential) |
| Schema required to read | Yes | Yes (or self-describing) | Yes |
| Mutable after build | Yes (in-place) | No (immutable buffer) | Yes (message objects) |

## When to pick which

**Cap'n Proto** — Best when you need zero-copy reads and in-place mutation. Good for IPC and memory-mapped files. Larger wire size due to alignment.

**FlatBuffers** — Best when you need zero-copy reads without mutation. Popular in games and mobile. Smaller than Cap'n Proto on the wire.

**Protocol Buffers** — Best when wire size matters most and you don't need zero-copy. Widest language and ecosystem support. Protobuf is the safe default if you're unsure.
