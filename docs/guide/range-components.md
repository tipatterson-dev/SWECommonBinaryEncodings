# Package 4 — Range Components

Package 4 defines range variants of four scalar components. A range component represents an interval `[low, high]` rather than a single value. These are used for uncertainty bounds, measurement ranges, or any case where a pair of values defines a span.

## CountRange

An integer interval.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `constraint` | AllowedValues | Valid value ranges |
| `nilValues` | list of NilValueInteger | Integer sentinels |
| `low` | int64 | Lower bound (inclusive) |
| `high` | int64 | Upper bound (inclusive) |

## QuantityRange

A continuous numeric interval with a unit of measure. Common uses: measurement uncertainty (e.g., temperature ± 0.5°C), sensor operating ranges, or validity windows.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `uom` | UnitReference | Unit of measure (required) |
| `constraint` | AllowedValues | Valid value ranges |
| `nilValues` | list of NilValueNumber | Numeric sentinels |
| `low` | NumberOrSpecial | Lower bound (inclusive) |
| `high` | NumberOrSpecial | Upper bound (inclusive) |

## TimeRange

A temporal interval. Use this for observation validity periods, forecast windows, or time-of-day ranges.

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `referenceTime` | string | ISO-8601 epoch origin |
| `localFrame` | string | URI — local temporal frame |
| `uom` | UnitReference | Unit of measure (required) |
| `constraint` | AllowedTimes | Valid temporal ranges |
| `nilValues` | list of NilValueTime | Temporal sentinels |
| `low` | DateTimeOrNumber | Start of interval (inclusive) |
| `high` | DateTimeOrNumber | End of interval (inclusive) |

## CategoryRange

An ordered pair of tokens from a controlled vocabulary. Less commonly used, but applicable when a code list has a natural ordering (e.g., severity levels, quality grades).

| Field | Type | Description |
|-------|------|-------------|
| `base` | AbstractSimpleComponent | Inherited metadata |
| `codeSpace` | string | URI to dictionary |
| `constraint` | AllowedTokens | Permitted tokens |
| `nilValues` | list of NilValueText | String sentinels |
| `low` | string | Start of range |
| `high` | string | End of range |

!!! note "No BooleanRange"
    There is no `BooleanRange` — a range of two booleans would be meaningless since the domain only has two values.

## When to use ranges vs. pairs of scalars

Use a range component when the `[low, high]` pair is semantically a single concept (an interval). If the two values are independent — for example, min and max daily temperatures that are separate measurements — use two separate `Quantity` fields in a `DataRecord` instead.
