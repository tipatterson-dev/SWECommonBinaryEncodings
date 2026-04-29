# Type Reference

Complete field-level reference for every type in the SWE Common 3.0 binary schemas. Types are grouped by package.

## Package 1 — Basic Types

### AbstractSWE

| Field | Cap'n Proto | FlatBuffers | Protobuf | Type | Description |
|-------|------------|-------------|----------|------|-------------|
| id | `id @0` | `id:string` | `string id = 1` | string | URI fragment identifier |

### AbstractSWEIdentifiable

| Field | Cap'n Proto | FlatBuffers | Protobuf | Type | Description |
|-------|------------|-------------|----------|------|-------------|
| base | `base @0` | `base:AbstractSWE` | `AbstractSWE base = 1` | AbstractSWE | Inherited |
| label | `label @1` | `label:string` | `string label = 2` | string | Human-readable name |
| description | `description @2` | `description:string` | `string description = 3` | string | Longer description |

### UnitReference

| Field | Cap'n Proto | FlatBuffers | Protobuf | Type | Description |
|-------|------------|-------------|----------|------|-------------|
| label | `label @0` | `label:string` | `string label = 1` | string | Unit name |
| symbol | `symbol @1` | `symbol:string` | `string symbol = 2` | string | Display symbol |
| code | `code @2` | `code:string` | `string code = 3` | string | UCUM code |
| href | `href @3` | `href:string` | `string href = 4` | string | URI to definition |

### NilValueText

| Field | Type | Description |
|-------|------|-------------|
| reason | string | URI — reason for nil |
| value | string | Sentinel value |

### NilValueInteger

| Field | Type | Description |
|-------|------|-------------|
| reason | string | URI — reason for nil |
| value | int64 | Sentinel value |

### NilValueNumber

| Field | Type | Description |
|-------|------|-------------|
| reason | string | URI — reason for nil |
| value | NumberOrSpecial | Sentinel value |

### NilValueTime

| Field | Type | Description |
|-------|------|-------------|
| reason | string | URI — reason for nil |
| value | DateTimeOrNumber | Sentinel value |

### AllowedValues

| Field | Type | Description |
|-------|------|-------------|
| values | list of NumberOrSpecial | Enumerated values |
| intervals | list of NumberInterval | Inclusive [low, high] ranges |
| significantFigures | uint8 | Precision (1–40; 0 = unset) |

### AllowedTokens

| Field | Type | Description |
|-------|------|-------------|
| values | list of string | Enumerated tokens |
| pattern | string | Regex pattern |

_Represented as a union (Cap'n Proto), enum discriminator (FlatBuffers), or oneof with nested TokenList (Protobuf)._

### AllowedTimes

| Field | Type | Description |
|-------|------|-------------|
| values | list of DateTimeOrNumber | Enumerated values |
| intervals | list of TimeInterval | Inclusive [low, high] ranges |
| significantFigures | uint8 | Precision |

### AssociationAttributeGroup

| Field | Type | Description |
|-------|------|-------------|
| href | string | URI-reference (required) |
| role | string | URI |
| arcrole | string | URI |
| title | string | Human-readable title |

---

## Package 2 — Abstract Components

### AbstractDataComponent

| Field | Type | Description |
|-------|------|-------------|
| identifiable | AbstractSWEIdentifiable | Inherited metadata |
| updatable | bool | Value can change externally |
| optional / is_optional | bool | Can be omitted in stream |
| definition | string | URI — semantic link |

### AbstractSimpleComponent

| Field | Type | Description |
|-------|------|-------------|
| dataComponent | AbstractDataComponent | Inherited metadata |
| referenceFrame | string | URI — CRS or temporal frame |
| axisID | string | CRS axis identifier |

---

## Package 3 — Scalar Components

### Boolean

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| value | bool | Truth value |

### Count

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| constraint | AllowedValues | Valid ranges |
| nilValues | list of NilValueInteger | Nil sentinels |
| value | int64 | Count value |

### Quantity

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| uom | UnitReference | Unit (required) |
| constraint | AllowedValues | Valid ranges |
| nilValues | list of NilValueNumber | Nil sentinels |
| value | NumberOrSpecial | Measured value |

### Text

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| constraint | AllowedTokens | Permitted values |
| nilValues | list of NilValueText | Nil sentinels |
| value | string | Text value |

### Category

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| codeSpace | string | URI to dictionary |
| constraint | AllowedTokens | Permitted tokens |
| nilValues | list of NilValueText | Nil sentinels |
| value | string | Category token |

### Time

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| referenceTime | string | ISO-8601 epoch |
| localFrame | string | URI — temporal frame |
| uom | UnitReference | Unit (required) |
| constraint | AllowedTimes | Valid ranges |
| nilValues | list of NilValueTime | Nil sentinels |
| value | DateTimeOrNumber | Temporal value |

---

## Package 4 — Range Components

### CountRange

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| constraint | AllowedValues | Valid ranges |
| nilValues | list of NilValueInteger | Nil sentinels |
| low | int64 | Lower bound |
| high | int64 | Upper bound |

### QuantityRange

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| uom | UnitReference | Unit (required) |
| constraint | AllowedValues | Valid ranges |
| nilValues | list of NilValueNumber | Nil sentinels |
| low | NumberOrSpecial | Lower bound |
| high | NumberOrSpecial | Upper bound |

### TimeRange

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| referenceTime | string | ISO-8601 epoch |
| localFrame | string | URI — temporal frame |
| uom | UnitReference | Unit (required) |
| constraint | AllowedTimes | Valid ranges |
| nilValues | list of NilValueTime | Nil sentinels |
| low | DateTimeOrNumber | Start |
| high | DateTimeOrNumber | End |

### CategoryRange

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractSimpleComponent | Inherited |
| codeSpace | string | URI to dictionary |
| constraint | AllowedTokens | Permitted tokens |
| nilValues | list of NilValueText | Nil sentinels |
| low | string | Start token |
| high | string | End token |

---

## Package 5 — Unions

### AnyScalarComponent

Union of: Boolean, Count, Quantity, Time, Category, Text

### AnySimpleComponent

Union of: all scalars + CountRange, QuantityRange, TimeRange, CategoryRange

### AnyComponent

Union of: all simple + DataRecord, Vector, DataArray, Matrix, DataChoice, Geometry

### ComponentOrRef

Union of: AnyComponent (inline) | AssociationAttributeGroup (ref)

### NamedComponent

| Field | Type | Description |
|-------|------|-------------|
| name | string | Name token |
| component | ComponentOrRef | The component |

---

## Package 6 — Records & Vectors

### DataRecord

| Field | Type | Description |
|-------|------|-------------|
| dataComponent | AbstractDataComponent | Inherited |
| fields | list of NamedComponent | Named fields (min 1) |

### Vector

| Field | Type | Description |
|-------|------|-------------|
| dataComponent | AbstractDataComponent | Inherited |
| referenceFrame | string | CRS URI (required) |
| localFrame | string | URI |
| coordinates | list of NamedCoordinate | Coordinate components |

---

## Package 7 — Choice

### DataChoice

| Field | Type | Description |
|-------|------|-------------|
| dataComponent | AbstractDataComponent | Inherited |
| choiceValue | Category | Discriminator |
| items | list of NamedComponent | Alternatives |

---

## Package 8 — Arrays & Streams

### DataArray

| Field | Type | Description |
|-------|------|-------------|
| dataComponent | AbstractDataComponent | Inherited |
| elementCount | ElementCountOrRef | Size |
| elementType | NamedComponent | Element structure |
| encoding | AnyEncoding | Serialization method |
| values | EncodedValues | Payload |

### Matrix

Same as DataArray plus:

| Field | Type | Description |
|-------|------|-------------|
| referenceFrame | string | CRS URI |
| localFrame | string | URI |

### DataStream

| Field | Type | Description |
|-------|------|-------------|
| identifiable | AbstractSWEIdentifiable | Inherited (not AbstractDataComponent) |
| elementType | NamedComponent | Record structure (required) |
| encoding | AnyEncoding | Serialization method (required) |
| values | AssociationAttributeGroup | Out-of-band link |

---

## Package 9 — Geometry

### Geometry

| Field | Type | Description |
|-------|------|-------------|
| dataComponent | AbstractDataComponent | Inherited |
| constraint | GeometryConstraint | Allowed types |
| nilValues | list of NilValueText | Nil sentinels |
| srs | string | CRS URI |
| value | GeoJsonGeometry | The geometry |

### GeoJsonGeometry

| Field | Type | Description |
|-------|------|-------------|
| type | GeometryType | Geometry type |
| coordinates | bytes | Packed float64 data |
| coordinatesJson | string | GeoJSON text fallback |

---

## Package 10 — Encodings

### TextEncoding

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractEncoding | Inherited |
| collapseWhiteSpaces | bool | Collapse whitespace |
| decimalSeparator | string | Default `"."` |
| tokenSeparator | string | Field delimiter (required) |
| blockSeparator | string | Record delimiter (required) |

### JSONEncoding

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractEncoding | Inherited |
| recordsAsArrays | bool | Default false |
| vectorsAsArrays | bool | Default false |

### XMLEncoding

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractEncoding | Inherited |
| namespace | string | XML namespace URI |

### BinaryEncoding

| Field | Type | Description |
|-------|------|-------------|
| base | AbstractEncoding | Inherited |
| byteOrder | ByteOrder | Endianness (required) |
| byteEncoding | ByteEncoding | raw or base64 (required) |
| byteLength | uint64 | Total length |
| members | list of BinaryMember | Layout (required, min 1) |

### AnyEncoding

Union of: TextEncoding, JSONEncoding, XMLEncoding, BinaryEncoding
