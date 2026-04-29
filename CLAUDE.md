# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

This repository translates the **OGC SWE Common Data Model 3.0** (standard OGC 24-014) into multiple binary encoding IDLs, one per subdirectory:

| Directory | File | Format |
|-----------|------|--------|
| `capnproto/` | `sweCommon3.capnp` | Cap'n Proto |
| `flatbuffers/` | `sweCommon3.fbs` | FlatBuffers |
| `protobuf/` | `sweCommon3.proto` | Protocol Buffers (proto3) |

All schemas cover the same ten packages from the OGC spec and must stay in sync with each other. New encodings should follow the same subdirectory convention.

## Compiling the schemas

**Cap'n Proto** (generates language bindings):
```sh
capnp compile -o<language> capnproto/sweCommon3.capnp   # e.g. -oc++, -ojava
```

**FlatBuffers** (generates language bindings):
```sh
flatc --<language> flatbuffers/sweCommon3.fbs             # e.g. --cpp, --java, --python
```

**Protocol Buffers** (generates language bindings):
```sh
protoc --<language>_out=<dir> --proto_path=protobuf protobuf/sweCommon3.proto  # e.g. --cpp_out, --java_out, --python_out
```

A `Makefile` wraps all three compilers (`make all`, `make capnproto`, `make flatbuffers`, `make protobuf`). Generated code lands in `gen/<format>/`. Compilation is the primary verification step.

## Architecture — 10-package structure

Both schemas mirror the OGC UML package layout:

1. **Basic Types** — `AbstractSWE`, `AbstractSWEIdentifiable`, `UnitReference`, `NumberOrSpecial`, `DateTimeOrNumber`, nil value types, constraint types (`AllowedValues`, `AllowedTokens`, `AllowedTimes`), `AssociationAttributeGroup`
2. **Abstract Data Component hierarchy** — `AbstractDataComponent`, `AbstractSimpleComponent`
3. **Simple (Scalar) Components** — `Boolean`, `Count`, `Quantity`, `Text`, `Category`, `Time`
4. **Range Components** — `CountRange`, `QuantityRange`, `TimeRange`, `CategoryRange`
5. **Polymorphic unions** — `AnyScalarComponent`, `AnySimpleComponent`, `AnyComponent`, `NamedComponent`
6. **Record Components** — `DataRecord`, `Vector`
7. **Choice Components** — `DataChoice`
8. **Block Components** — `DataArray`, `Matrix`, `DataStream`
9. **Geometry Components** (new in 3.0) — `Geometry`, `GeoJsonGeometry`, `GeometryConstraint`
10. **Encodings** — `TextEncoding`, `JSONEncoding`, `XMLEncoding`, `BinaryEncoding`, `AnyEncoding`

## Key design decisions (apply to both schemas)

**Inheritance → embedded base structs/tables.** Neither IDL supports class inheritance. Every concrete type embeds its abstract base as a named field (`base`, `dataComponent`, `identifiable`) rather than flattening or duplicating fields. This preserves the OGC field hierarchy at each level.

**Polymorphism → unions.** OGC's `AnyComponent`, `AnySimpleComponent`, etc. are expressed as Cap'n Proto unnamed unions / FlatBuffers union types.

**`DataStream` extends `AbstractSWEIdentifiable`, not `AbstractDataComponent`** — unlike all other composite types. Its `values` field is always an out-of-band link (`AssociationAttributeGroup`), not inline data.

## Cap'n Proto–specific notes

- Field ordinals (`@0`, `@1`, …) **must never be renumbered or reused** — they are the wire format.
- The file ID `@0xb3a4f7c8e2d19056` must remain stable.
- `NumberOrSpecial` and `DateTimeOrNumber` use native Cap'n Proto unnamed unions.
- There is no declared root type; callers wrap the top-level struct themselves.

## Protobuf-specific notes

- Syntax: `proto3`. Package: `ogc.swecommon`.
- Language options set for Java (`org.ogc.swecommon.SweCommonProto`) and Go (`ogc.org/swecommon`).
- Enum values use `SCREAMING_SNAKE_CASE` prefixed with the enum name (e.g., `GEOMETRY_TYPE_POINT`, `BYTE_ORDER_BIG_ENDIAN`) per the Protobuf style guide. Every enum has an `_UNSPECIFIED = 0` sentinel.
- `oneof` is used for all polymorphic associations (`AnyComponent`, `ComponentOrRef`, `AnyEncoding`, etc.). Proto3 `oneof` cannot contain `repeated` fields, so `AllowedTokens` uses a nested `TokenList` message wrapping `repeated string`.
- `optional` keyword is used on scalar fields where presence tracking matters (e.g., `Boolean.value`, `Count.value`, `AbstractDataComponent.is_optional`).
- The OGC field name `optional` is renamed to `is_optional` to avoid collision with the proto3 `optional` keyword.
- Root message is `SweCommonMessage` with a `oneof root { AnyComponent, DataStream }`.

## FlatBuffers–specific notes

- Namespace: `ogc.swecommon`.
- Root type is `SweCommonMessage { root: SweCommonRoot }` — file identifier `"SWEC"`, extension `".swe"`.
- **`AnyComponentWrapper` exists solely as a workaround**: FlatBuffers unions cannot directly contain other unions, so `ComponentOrRef` wraps `AnyComponent` in a table first.
- `DateTimeOrNumber` uses an explicit enum discriminator (`DateTimeKind`) + separate fields because FlatBuffers tables cannot have inline unions of scalar/string combinations the way Cap'n Proto can.
- `AllowedTokens` similarly uses a `AllowedTokensKind` enum discriminator instead of a union.
- Fields marked `(required)` enforce non-null at serialisation time.