# Package 7 — Choice Components

Package 7 defines `DataChoice`, a disjoint union type for modeling alternatives in a data stream.

## DataChoice

A DataChoice describes a set of named component alternatives — at runtime, exactly one of the items is present. The `choiceValue` field acts as a discriminator in the encoded data stream, telling the decoder which alternative was selected.

| Field | Type | Description |
|-------|------|-------------|
| `dataComponent` | AbstractDataComponent | Inherited metadata |
| `choiceValue` | Category | Discriminator — its value names the selected item |
| `items` | list of NamedComponent | The available alternatives (min 1) |

### How it works

The `choiceValue` is a `Category` component whose valid tokens correspond to the `name` fields of the items. When encoding, the value of `choiceValue` tells the reader which item structure follows in the stream.

### Example: multi-format sensor output

A sensor that can output either a scalar reading or a full spectrum:

```
DataChoice "SensorOutput"
  choiceValue: Category (values: ["scalar", "spectrum"])
  items:
  ├── scalar: Quantity (uom: "W/m2")
  └── spectrum: DataArray
        elementType: Quantity (uom: "W/m2/nm")
        elementCount: 256
```

### DataChoice vs. language-level unions

The `AnyComponent` union (Package 5) is a schema-level construct — it's built into the IDL and resolved at deserialization time. `DataChoice` is a data-level construct — it lives inside the data stream and is resolved by reading the discriminator value at runtime. Use `DataChoice` when the set of alternatives is defined by the data model, not by the schema.

=== "Cap'n Proto"

    ```capnp
    struct DataChoice {
      dataComponent @0 :BT.AbstractDataComponent;
      choiceValue   @1 :SC.Category;
      items         @2 :List(NamedComponent);
    }
    ```

=== "FlatBuffers"

    ```fbs
    table DataChoice {
      data_component:AbstractDataComponent;
      choice_value:Category;
      items:[NamedComponent] (required);
    }
    ```

=== "Protocol Buffers"

    ```protobuf
    message DataChoice {
      AbstractDataComponent data_component = 1;
      Category choice_value = 2;
      repeated NamedComponent items = 3;
    }
    ```
