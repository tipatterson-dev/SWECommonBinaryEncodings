# Package 2 — Abstract Data Component Hierarchy

Package 2 defines the two abstract base types that every concrete data component inherits from. Since none of the three IDLs support class inheritance, these are represented as **embedded structs/tables** inside each concrete type.

## AbstractDataComponent

The common metadata carried by every data component in the model. This is the primary base type — `DataRecord`, `DataArray`, `Quantity`, and nearly every other component embeds it.

| Field | Type | Description |
|-------|------|-------------|
| `identifiable` | AbstractSWEIdentifiable | Inherited id, label, description |
| `updatable` | bool | Can the value change externally after initial assignment? |
| `optional` | bool | Can this component be omitted in a data stream? |
| `definition` | string | URI — semantic link to a concept definition |

!!! note "Field naming: `optional`"
    The OGC field name `optional` collides with the `optional` keyword in proto3. The Protobuf schema renames this field to `is_optional`. The Cap'n Proto and FlatBuffers schemas retain the original name.

### How it's embedded

=== "Cap'n Proto"

    ```capnp
    struct DataRecord {
      dataComponent @0 :BT.AbstractDataComponent;
      fields        @1 :List(NamedComponent);
    }
    ```

=== "FlatBuffers"

    ```fbs
    table DataRecord {
      data_component:AbstractDataComponent;
      fields:[NamedComponent] (required);
    }
    ```

=== "Protocol Buffers"

    ```protobuf
    message DataRecord {
      AbstractDataComponent data_component = 1;
      repeated NamedComponent fields = 2;
    }
    ```

The pattern is the same everywhere: access `my_record.data_component.identifiable.label` to get the human-readable name of a DataRecord instance.

## AbstractSimpleComponent

An extension of `AbstractDataComponent` that adds reference frame metadata. This is the base for all scalar components (Package 3) and range components (Package 4).

| Field | Type | Description |
|-------|------|-------------|
| `dataComponent` | AbstractDataComponent | All inherited metadata |
| `referenceFrame` | string | URI-reference — coordinate reference system or temporal frame |
| `axisID` | string | Axis identifier within the CRS |

The `referenceFrame` is particularly important for spatial and temporal components. For example, a `Quantity` measuring altitude might set `referenceFrame` to `"http://www.opengis.net/def/crs/EPSG/0/5714"` (EGM2008 geoid height) and `axisID` to `"h"`.

## Inheritance chain

Every concrete component embeds its ancestor chain as nested fields. The full access path depends on the component level:

```
Scalar components (Quantity, Time, etc.):
  └─ base: AbstractSimpleComponent
       └─ dataComponent: AbstractDataComponent
            └─ identifiable: AbstractSWEIdentifiable
                 └─ base: AbstractSWE

Composite components (DataRecord, DataArray, etc.):
  └─ dataComponent: AbstractDataComponent
       └─ identifiable: AbstractSWEIdentifiable
            └─ base: AbstractSWE

DataStream (special case):
  └─ identifiable: AbstractSWEIdentifiable
       └─ base: AbstractSWE
```

!!! info "Why not flatten?"
    Flattening the base fields into each concrete type would reduce nesting but would duplicate field definitions across dozens of types. Embedding preserves a single source of truth for each abstraction level and mirrors the OGC UML hierarchy faithfully.
