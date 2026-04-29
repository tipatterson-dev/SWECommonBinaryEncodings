# OGC SWE Common 3.0 — Binary Encodings

This project provides binary serialization schemas for the **OGC SWE Common Data Model 3.0** (standard [OGC 24-014](https://docs.ogc.org/is/24-014/24-014.html)) in three encoding formats:

| Format | Schema file | Directory |
|--------|------------|-----------|
| **Cap'n Proto** | `sweCommon3.capnp` | `capnproto/` |
| **FlatBuffers** | `sweCommon3.fbs` | `flatbuffers/` |
| **Protocol Buffers** | `sweCommon3.proto` | `protobuf/` |

All three schemas cover the same ten packages from the OGC specification and are kept in sync with each other.

## What is SWE Common?

The **Sensor Web Enablement (SWE) Common Data Model** is an OGC standard that defines a framework for describing sensor data — observation values, data streams, and the encoding rules that govern how those values are serialized on the wire. Version 3.0 adds geometry support and JSON encoding to the model.

The data model is built from composable component types: scalar values like `Quantity` and `Time`, composite structures like `DataRecord` and `DataArray`, and encoding descriptors like `TextEncoding` and `BinaryEncoding`. These components can be nested arbitrarily to describe complex sensor output structures.

## Why binary encodings?

The OGC specification defines the data model in UML and provides XML Schema (XSD) bindings. This project translates that model into three popular binary serialization frameworks, giving you:

- **Zero-copy deserialization** (Cap'n Proto, FlatBuffers) — read fields directly from the wire buffer without parsing
- **Compact wire format** — significantly smaller payloads than XML
- **Cross-language code generation** — produce typed APIs in C++, Java, Python, Go, Rust, and more from a single schema
- **Schema evolution** — all three formats support adding fields without breaking existing readers

## Project structure

```
BinaryEncodings/
├── capnproto/
│   ├── sweCommon3.capnp        ← root (Packages 5–8)
│   ├── basic_types.capnp       ← Packages 1–2
│   ├── scalar_components.capnp ← Packages 3–4
│   ├── geometry.capnp          ← Package 9
│   └── encodings.capnp         ← Package 10
├── flatbuffers/
│   ├── sweCommon3.fbs          ← root (Packages 5–8)
│   ├── basic_types.fbs         ← Packages 1–2
│   ├── scalar_components.fbs   ← Packages 3–4
│   ├── geometry.fbs            ← Package 9
│   └── encodings.fbs           ← Package 10
├── protobuf/
│   ├── sweCommon3.proto        ← root (Packages 5–8)
│   ├── basic_types.proto       ← Packages 1–2
│   ├── scalar_components.proto ← Packages 3–4
│   ├── geometry.proto          ← Package 9
│   └── encodings.proto         ← Package 10
├── gen/                        ← generated code (not committed)
├── Makefile
└── docs/                       ← this documentation
```

## Quick links

- [Installation & compilation](getting-started/installation.md) — get the compilers and generate code
- [Quick Start tutorial](getting-started/quickstart.md) — serialize your first DataRecord
- [Conceptual Guide](guide/overview.md) — understand each of the 10 packages
- [Encoding Comparison](comparison.md) — side-by-side comparison of how each concept maps across formats
- [Architecture diagrams](architecture.md) — visual overview of the type hierarchy
