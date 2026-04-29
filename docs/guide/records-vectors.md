# Package 6 — Records & Vectors

Package 6 defines two composite types for grouping named components: `DataRecord` for heterogeneous field collections and `Vector` for coordinate tuples.

## DataRecord

An ISO-11404 Record — an ordered sequence of named fields. This is the workhorse composite type for structuring observation data. A weather station output, an IMU reading, a water quality sample — all naturally map to a DataRecord.

| Field | Type | Description |
|-------|------|-------------|
| `dataComponent` | AbstractDataComponent | Inherited metadata |
| `fields` | list of NamedComponent | Ordered named fields (min 1) |

### Example: weather observation

A DataRecord with three fields:

```
DataRecord "WeatherObs"
├── temperature: Quantity (uom: "Cel")
├── humidity: Quantity (uom: "%")
└── timestamp: Time (ISO-8601)
```

DataRecords can nest — a field's component can itself be another DataRecord, a DataArray, or any other component type via the `AnyComponent` union.

## Vector

A mathematical vector — a list of scalar coordinates in a reference frame. While superficially similar to a DataRecord, a Vector is semantically different: its components represent coordinates in a coordinate reference system (CRS), and the `referenceFrame` field is required.

| Field | Type | Description |
|-------|------|-------------|
| `dataComponent` | AbstractDataComponent | Inherited metadata |
| `referenceFrame` | string | URI-reference to a CRS (required) |
| `localFrame` | string | URI-reference — frame located by this vector |
| `coordinates` | list of NamedCoordinate | The coordinate components |

### CoordinateComponent

Vector coordinates are restricted to three scalar types: `Count`, `Quantity`, or `Time`. This is a narrower union than `AnyScalarComponent`.

=== "Cap'n Proto"

    ```capnp
    struct CoordinateComponent {
      union {
        count    @0 :SC.Count;
        quantity @1 :SC.Quantity;
        time     @2 :SC.Time;
      }
    }
    ```

=== "FlatBuffers"

    ```fbs
    union CoordinateComponent { Count, Quantity, Time }
    ```

=== "Protocol Buffers"

    ```protobuf
    message CoordinateComponent {
      oneof coordinate {
        Count count = 1;
        Quantity quantity = 2;
        Time time = 3;
      }
    }
    ```

### Example: WGS84 position

```
Vector "Position"
  referenceFrame: "http://www.opengis.net/def/crs/EPSG/0/4326"
  coordinates:
  ├── lat: Quantity (uom: "deg", axisID: "Lat")
  ├── lon: Quantity (uom: "deg", axisID: "Lon")
  └── alt: Quantity (uom: "m", axisID: "h")
```

## DataRecord vs. Vector

| Aspect | DataRecord | Vector |
|--------|-----------|--------|
| Purpose | General-purpose grouping | Coordinate tuples |
| Field types | Any component | Count, Quantity, or Time only |
| Reference frame | Not required | Required |
| Nesting | Fields can contain any component | Coordinates are leaf-level scalars |
