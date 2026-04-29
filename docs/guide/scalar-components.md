# Package 3 — Scalar Components

Package 3 defines six scalar component types — the leaf-level building blocks that hold actual observation values. Each embeds `AbstractSimpleComponent` as its base.

## Boolean

A simple truth value. The only scalar that carries no constraints or nil values.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `value` | bool | The truth value |

## Count

A discrete counting value represented as an integer. Used for things like pixel counts, sample indices, or event tallies.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `constraint` | AllowedValues | Valid value ranges/enumeration |
| `nilValues` | list of NilValueInteger | Integer sentinel values for "no data" |
| `value` | int64 | The count value |

## Quantity

A continuous measured value with a unit of measure — the most commonly used component type. Temperature, pressure, velocity, concentration — any physical measurement is a `Quantity`.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `uom` | UnitReference | Unit of measure (required) |
| `constraint` | AllowedValues | Valid value ranges/enumeration |
| `nilValues` | list of NilValueNumber | Numeric sentinels for "no data" |
| `value` | NumberOrSpecial | The measured value (may be NaN/±Inf) |

!!! tip "Always set the `uom`"
    The OGC spec requires a unit of measure on every `Quantity`. Use [UCUM codes](https://ucum.org/ucum) in the `code` field — e.g., `"Cel"` for Celsius, `"m"` for meters, `"Pa"` for pascals.

## Text

A free-form textual value. Use this when no controlled vocabulary exists for the data.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `constraint` | AllowedTokens | Permitted values or regex pattern |
| `nilValues` | list of NilValueText | String sentinels for "no data" |
| `value` | string | The text value |

## Category

A token from a controlled vocabulary — essentially a string value constrained to a code list. Use this instead of `Text` when values come from a defined set (e.g., cloud cover categories, quality flags).

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `codeSpace` | string | URI pointing to the dictionary/code list |
| `constraint` | AllowedTokens | Permitted tokens or pattern |
| `nilValues` | list of NilValueText | String sentinels for "no data" |
| `value` | string | The category token |

## Time

A temporal instant — either an ISO-8601 date-time string or a numeric offset from a reference epoch. Used for timestamps, durations, and temporal coordinates.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `referenceTime` | string | ISO-8601 epoch origin (e.g., "1970-01-01T00:00:00Z") |
| `localFrame` | string | URI — local temporal reference frame |
| `uom` | UnitReference | Unit of measure (required) |
| `constraint` | AllowedTimes | Valid temporal values/intervals |
| `nilValues` | list of NilValueTime | Temporal sentinels for "no data" |
| `value` | DateTimeOrNumber | The temporal value |

!!! note "ISO-8601 vs numeric time"
    When `value` is a `dateTime` string, `uom` should reference the ISO-8601/Gregorian calendar. When `value` is numeric, `uom` specifies the time unit (e.g., `"s"` for seconds) and `referenceTime` anchors the epoch.

## Common patterns

All six scalars share the same general structure:

1. **Base metadata** — label, description, definition URI, reference frame
2. **Constraints** — what values are valid
3. **Nil values** — what sentinels mean "no data" and why
4. **Value** — the actual observation

When building a component, you typically populate the metadata and constraints at schema definition time, and fill in the `value` at runtime when encoding observations.
