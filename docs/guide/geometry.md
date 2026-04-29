# Package 9 — Geometry Components

Package 9 is new in SWE Common 3.0 and adds support for ISO-19107 geometry within the data model. Geometry values are represented in a GeoJSON-compatible format.

## GeometryType

An enumeration of the six standard geometry types from ISO-19107 / GeoJSON:

| Value | Description |
|-------|-------------|
| `Point` | Single coordinate position |
| `MultiPoint` | Collection of points |
| `LineString` | Ordered sequence of positions forming a line |
| `MultiLineString` | Collection of line strings |
| `Polygon` | Closed ring(s) forming an area |
| `MultiPolygon` | Collection of polygons |

=== "Cap'n Proto"

    ```capnp
    enum GeometryType {
      point           @0;
      multiPoint      @1;
      lineString      @2;
      multiLineString @3;
      polygon         @4;
      multiPolygon    @5;
    }
    ```

=== "FlatBuffers"

    ```fbs
    enum GeometryType : byte {
      Point = 0, MultiPoint, LineString,
      MultiLineString, Polygon, MultiPolygon
    }
    ```

=== "Protocol Buffers"

    ```protobuf
    enum GeometryType {
      GEOMETRY_TYPE_UNSPECIFIED = 0;
      GEOMETRY_TYPE_POINT = 1;
      GEOMETRY_TYPE_MULTI_POINT = 2;
      GEOMETRY_TYPE_LINE_STRING = 3;
      GEOMETRY_TYPE_MULTI_LINE_STRING = 4;
      GEOMETRY_TYPE_POLYGON = 5;
      GEOMETRY_TYPE_MULTI_POLYGON = 6;
    }
    ```

!!! note "Protobuf enum conventions"
    Protobuf enums use `SCREAMING_SNAKE_CASE` prefixed with the enum name and include an `_UNSPECIFIED = 0` sentinel per the proto3 style guide.

## GeoJsonGeometry

A simplified GeoJSON Geometry for wire use. Coordinates can be stored as a packed binary blob of Float64 values (efficient for large geometries) or as a JSON text fallback.

| Field | Type | Description |
|-------|------|-------------|
| `type` | GeometryType | The geometry type |
| `coordinates` | bytes | Packed float64 coordinate data |
| `coordinatesJson` | string | Full GeoJSON coordinates as text fallback |

The `coordinates` field stores raw packed doubles — the nesting structure (arrays of arrays for polygons, etc.) is implied by the `type`. The `coordinatesJson` field provides interoperability with standard GeoJSON parsers when the packed binary form isn't suitable.

## GeometryConstraint

Restricts which geometry types are permitted for a `Geometry` component.

| Field | Type | Description |
|-------|------|-------------|
| `geomTypes` | list of GeometryType | Allowed geometry types |

## Geometry

The main geometry component type. It embeds `AbstractDataComponent` (like other composite components) and adds geometry-specific fields.

| Field | Type | Description |
|-------|------|-------------|
| `dataComponent` | AbstractDataComponent | Inherited metadata |
| `constraint` | GeometryConstraint | Allowed geometry types |
| `nilValues` | list of NilValueText | Sentinels for "no geometry" |
| `srs` | string | URI — coordinate reference system |
| `value` | GeoJsonGeometry | The geometry value |

### Example: sensor footprint

```
Geometry "footprint"
  srs: "http://www.opengis.net/def/crs/EPSG/0/4326"
  constraint: [Polygon]
  value: GeoJsonGeometry
    type: Polygon
    coordinatesJson: "[[[0,0],[1,0],[1,1],[0,1],[0,0]]]"
```

`Geometry` participates in the `AnyComponent` union (Package 5), so it can appear anywhere a component is expected — as a field in a DataRecord, an element type in a DataArray, etc.
