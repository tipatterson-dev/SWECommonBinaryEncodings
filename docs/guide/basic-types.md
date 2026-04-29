# Package 1 — Basic Types

Package 1 defines the foundational value types used throughout the data model: identification metadata, unit references, special numeric values, nil sentinels, and constraint types.

## AbstractSWE

The root base type for all SWE Common objects (other than value objects). It carries a single optional `id` field — a URI fragment identifier that makes the object referenceable.

=== "Cap'n Proto"

    ```capnp
    struct AbstractSWE {
      id @0 :Text;
    }
    ```

=== "FlatBuffers"

    ```fbs
    table AbstractSWE {
      id:string;
    }
    ```

=== "Protocol Buffers"

    ```protobuf
    message AbstractSWE {
      string id = 1;
    }
    ```

## AbstractSWEIdentifiable

Extends `AbstractSWE` with human-readable metadata. Most concrete types embed this (via their `AbstractDataComponent` base) to carry a label and description.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSWE | Inherited id |
| `label` | string | Short human-readable name |
| `description` | string | Longer explanation |

## UnitReference

A reference to a unit of measure. Typically you'll set the `code` field to a [UCUM](https://ucum.org/) code (e.g., `"Cel"` for Celsius, `"m/s"` for meters per second). The `href` field can point to a full unit definition URI when UCUM doesn't cover your needs.

| Field | Type | Description |
|-------|------|-------------|
| `label` | string | Human-readable unit name |
| `symbol` | string | Display symbol (e.g., "°C") |
| `code` | string | UCUM code |
| `href` | string | URI to unit definition |

## NumberOrSpecial

A numeric value that can also represent IEEE-754 special values. This is the building block for constraint ranges and `Quantity` values.

=== "Cap'n Proto"

    Uses a native unnamed union:

    ```capnp
    struct NumberOrSpecial {
      union {
        number @0 :Float64;
        nan    @1 :Void;
        posInf @2 :Void;
        negInf @3 :Void;
      }
    }
    ```

=== "FlatBuffers"

    Uses an enum discriminator with separate fields (FlatBuffers tables cannot union scalars and strings inline):

    ```fbs
    enum NumberOrSpecialKind : byte { Number = 0, NaN, PosInf, NegInf }
    table NumberOrSpecial {
      kind:NumberOrSpecialKind = Number;
      number:double;
    }
    ```

=== "Protocol Buffers"

    Uses a `oneof`:

    ```protobuf
    message NumberOrSpecial {
      oneof value {
        double number = 1;
        bool nan = 2;
        bool pos_inf = 3;
        bool neg_inf = 4;
      }
    }
    ```

## DateTimeOrNumber

Similar to `NumberOrSpecial` but adds an ISO-8601 date-time string variant. Used by `Time` components and temporal constraints.

The union variants are: `dateTime` (ISO-8601 string), `number` (Float64), `nan`, `posInf`, `negInf`.

## Nil values

Nil value types define sentinel values that stand in for "no data" along with a reason URI explaining why. There are four variants matching the value domains of the scalar components:

| Type | Value field type | Used by |
|------|-----------------|---------|
| `NilValueText` | string | Text, Category |
| `NilValueInteger` | int64 | Count |
| `NilValueNumber` | NumberOrSpecial | Quantity |
| `NilValueTime` | DateTimeOrNumber | Time |

Each carries a `reason` field (URI) and a `value` field with the sentinel.

## Constraints

Constraint types restrict the domain of valid values for a component.

### AllowedValues

Constrains numeric values by enumeration and/or inclusive intervals. Used by `Count`, `Quantity`, and their range counterparts.

| Field | Type | Description |
|-------|------|-------------|
| `values` | list of NumberOrSpecial | Enumerated permitted values |
| `intervals` | list of NumberInterval | Inclusive [low, high] ranges |
| `significantFigures` | uint8 | Precision (1–40; 0 = unset) |

### AllowedTokens

Constrains string values by enumeration or regex pattern. Used by `Text` and `Category`.

=== "Cap'n Proto"

    Uses an unnamed union — either a list of values or a regex pattern:

    ```capnp
    struct AllowedTokens {
      union {
        values  @0 :List(Text);
        pattern @1 :Text;
      }
    }
    ```

=== "FlatBuffers"

    Uses an enum discriminator (`AllowedTokensKind`) because FlatBuffers can't union a vector with a scalar.

=== "Protocol Buffers"

    Proto3 `oneof` cannot contain `repeated` fields, so a nested `TokenList` message wraps the string list:

    ```protobuf
    message AllowedTokens {
      message TokenList {
        repeated string values = 1;
      }
      oneof constraint {
        TokenList value_list = 1;
        string pattern = 2;
      }
    }
    ```

### AllowedTimes

Same structure as `AllowedValues` but over the `DateTimeOrNumber` domain. Used by `Time` and `TimeRange`.

## AssociationAttributeGroup

An XLink-style by-reference association used throughout the model to point to external resources (e.g., out-of-band stream values, referenced components).

| Field | Type | Description |
|-------|------|-------------|
| `href` | string | URI-reference (required) |
| `role` | string | URI describing the role |
| `arcrole` | string | URI describing the arc role |
| `title` | string | Human-readable title |
