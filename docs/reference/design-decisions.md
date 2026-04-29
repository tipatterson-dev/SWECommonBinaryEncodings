# Design Decisions

This page documents the key design decisions made when translating the OGC SWE Common 3.0 UML model into binary serialization schemas. These decisions apply across all three formats unless noted otherwise.

## Inheritance → embedded base structs

**Problem:** None of the three IDLs (Cap'n Proto, FlatBuffers, Protocol Buffers) support class inheritance. The OGC UML model uses inheritance extensively — every component inherits from `AbstractDataComponent`, which inherits from `AbstractSWEIdentifiable`, which inherits from `AbstractSWE`.

**Decision:** Every concrete type embeds its abstract base as a named field rather than flattening or duplicating the base fields.

**Rationale:** Embedding preserves the OGC field hierarchy at each level and avoids duplicating field definitions across dozens of types. The trade-off is deeper nesting when accessing base fields (e.g., `quantity.base.dataComponent.identifiable.label`), but this mirrors the conceptual model faithfully and keeps a single source of truth for each abstraction level.

**Alternative considered:** Flattening all base fields into each concrete type. This was rejected because it would duplicate ~10 fields across 20+ types, making schema maintenance error-prone and obscuring the conceptual hierarchy.

## Polymorphism → unions

**Problem:** The OGC model defines polymorphic associations (`AnyComponent`, `AnySimpleComponent`, etc.) where a field can hold any concrete component type.

**Decision:** These are expressed as discriminated unions — Cap'n Proto unnamed unions, FlatBuffers `union` types, and Protobuf `oneof`.

**Rationale:** All three IDLs have native union/oneof support that maps directly to the OGC polymorphic pattern. The union approach is type-safe and adds no overhead beyond the discriminant tag.

## DataStream extends AbstractSWEIdentifiable, not AbstractDataComponent

**Problem:** In the OGC UML, `DataStream` is the only composite type that does not inherit from `AbstractDataComponent`. It inherits from `AbstractSWEIdentifiable` instead.

**Decision:** The schemas faithfully reproduce this distinction. `DataStream` embeds `identifiable: AbstractSWEIdentifiable` while all other composite types embed `dataComponent: AbstractDataComponent`.

**Rationale:** A `DataStream` is a stream descriptor, not a data component. It doesn't carry `updatable`, `optional`, or `definition` fields because those concepts don't apply to a stream-level object.

## Cap'n Proto: stable file IDs and ordinals

**Problem:** Cap'n Proto uses file IDs and field ordinals as part of the wire format. Changing them breaks backward compatibility.

**Decision:** Each `.capnp` file has a unique, stable `@0x...` file ID. Field ordinals (`@0`, `@1`, ...) are assigned sequentially and must never be renumbered or reused.

**Rationale:** This is a hard requirement of the Cap'n Proto format. Violating it would silently corrupt data.

## Cap'n Proto: no declared root type

**Problem:** Cap'n Proto does not have a `root_type` declaration like FlatBuffers.

**Decision:** No root type is declared. Callers use `initRoot<T>()` with whatever top-level type they need (e.g., `DataRecord`, `DataStream`).

**Rationale:** Cap'n Proto's API is designed around caller-chosen root types. Adding a wrapper would add unnecessary indirection.

## FlatBuffers: AnyComponentWrapper

**Problem:** FlatBuffers unions cannot directly contain other unions. `ComponentOrRef` needs to union `AnyComponent` (itself a union) with `AssociationAttributeGroup`.

**Decision:** An `AnyComponentWrapper` table wraps `AnyComponent` so it can participate in the `ComponentOrRef` union.

**Rationale:** This is the standard FlatBuffers workaround for nested unions. The wrapper adds one level of indirection but no extra bytes on the wire (FlatBuffers tables are already indirect).

## FlatBuffers: DateTimeOrNumber uses enum discriminator

**Problem:** FlatBuffers tables cannot have inline unions of scalar/string combinations the way Cap'n Proto can.

**Decision:** `DateTimeOrNumber` uses an explicit `DateTimeKind` enum discriminator with separate fields for the date-time string and numeric value.

**Rationale:** The enum discriminator pattern is idiomatic FlatBuffers and avoids the need for wrapper tables around each scalar variant.

## FlatBuffers: file identifier and root type

**Decision:** The FlatBuffers schema declares `root_type SweCommonMessage`, file identifier `"SWEC"`, and file extension `".swe"`.

**Rationale:** FlatBuffers file identifiers allow quick validation of buffer type without full deserialization. The four-character identifier `"SWEC"` is short for "SWE Common".

## Protobuf: field naming

**Problem:** The OGC field name `optional` is a reserved keyword in proto3.

**Decision:** The field is renamed to `is_optional` in the Protobuf schema.

**Rationale:** Proto3 reserves `optional` as a field presence modifier. Renaming to `is_optional` is the minimal change that avoids the collision while remaining semantically clear.

## Protobuf: enum naming conventions

**Decision:** All enum values use `SCREAMING_SNAKE_CASE` prefixed with the enum name, and every enum has an `_UNSPECIFIED = 0` sentinel.

**Rationale:** This follows the official [Protocol Buffers style guide](https://protobuf.dev/programming-guides/style/). The prefix avoids name collisions (proto3 enums are open, so values share a namespace). The zero sentinel ensures proto3's default value is always "unspecified" rather than accidentally meaningful.

## Protobuf: AllowedTokens uses nested TokenList

**Problem:** Proto3 `oneof` cannot contain `repeated` fields.

**Decision:** A nested `TokenList` message wraps `repeated string values` so it can appear inside the `oneof`.

**Rationale:** This is the standard proto3 workaround. The nested message adds no wire overhead beyond the message framing.

## Protobuf: language options

**Decision:** The proto schema sets `java_package`, `java_outer_classname`, and `go_package` options.

**Rationale:** These are the three most common language targets. Other languages can be added as needed without affecting the wire format.

## Packages 5–8 in a single file

**Problem:** `AnyComponent` references `DataRecord`, `DataArray`, etc., which in turn reference `AnyComponent` (via `NamedComponent`). This creates a circular dependency.

**Decision:** Packages 5–8 are kept in the root schema file (`sweCommon3.*`), while independent packages are split into separate files.

**Rationale:** None of the three IDLs support circular imports across files. Keeping the mutually referential types together is the only option. The independent packages (basic types, scalar components, geometry, encodings) are split out to keep files manageable.
