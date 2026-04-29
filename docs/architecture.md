# Architecture

Visual overview of the SWE Common 3.0 type hierarchy and how components compose.

## Type inheritance hierarchy

This diagram shows how every concrete type traces back to its abstract base through embedded fields.

```mermaid
classDiagram
    class AbstractSWE {
        +string id
    }
    class AbstractSWEIdentifiable {
        +AbstractSWE base
        +string label
        +string description
    }
    class AbstractDataComponent {
        +AbstractSWEIdentifiable identifiable
        +bool updatable
        +bool optional
        +string definition
    }
    class AbstractSimpleComponent {
        +AbstractDataComponent dataComponent
        +string referenceFrame
        +string axisID
    }

    AbstractSWE <|-- AbstractSWEIdentifiable
    AbstractSWEIdentifiable <|-- AbstractDataComponent
    AbstractDataComponent <|-- AbstractSimpleComponent

    AbstractSimpleComponent <|-- Boolean
    AbstractSimpleComponent <|-- Count
    AbstractSimpleComponent <|-- Quantity
    AbstractSimpleComponent <|-- Text
    AbstractSimpleComponent <|-- Category
    AbstractSimpleComponent <|-- Time
    AbstractSimpleComponent <|-- CountRange
    AbstractSimpleComponent <|-- QuantityRange
    AbstractSimpleComponent <|-- TimeRange
    AbstractSimpleComponent <|-- CategoryRange

    AbstractDataComponent <|-- DataRecord
    AbstractDataComponent <|-- Vector
    AbstractDataComponent <|-- DataChoice
    AbstractDataComponent <|-- DataArray
    AbstractDataComponent <|-- Matrix
    AbstractDataComponent <|-- Geometry

    AbstractSWEIdentifiable <|-- DataStream

    note for DataStream "Extends Identifiable,\nnot DataComponent"
```

!!! note
    The `<|--` arrows represent conceptual inheritance. In the actual schemas, this is implemented as embedded structs/tables, not language-level inheritance.

## Component composition

This diagram shows how composite types reference other components through the union system.

```mermaid
graph TD
    subgraph "Scalar Components (Pkg 3)"
        Boolean
        Count
        Quantity
        TextComp["Text"]
        Category
        Time
    end

    subgraph "Range Components (Pkg 4)"
        CountRange
        QuantityRange
        TimeRange
        CategoryRange
    end

    subgraph "Unions (Pkg 5)"
        AnyScalar["AnyScalarComponent"]
        AnySimple["AnySimpleComponent"]
        AnyComp["AnyComponent"]
        CompOrRef["ComponentOrRef"]
        Named["NamedComponent"]
    end

    subgraph "Composites (Pkg 6-8)"
        DataRecord
        Vector
        DataChoice
        DataArray
        Matrix
        DataStream
    end

    subgraph "Geometry (Pkg 9)"
        Geometry
    end

    Boolean --> AnyScalar
    Count --> AnyScalar
    Quantity --> AnyScalar
    TextComp --> AnyScalar
    Category --> AnyScalar
    Time --> AnyScalar

    AnyScalar --> AnySimple
    CountRange --> AnySimple
    QuantityRange --> AnySimple
    TimeRange --> AnySimple
    CategoryRange --> AnySimple

    AnySimple --> AnyComp
    DataRecord --> AnyComp
    Vector --> AnyComp
    DataChoice --> AnyComp
    DataArray --> AnyComp
    Matrix --> AnyComp
    Geometry --> AnyComp

    AnyComp --> CompOrRef
    CompOrRef --> Named

    Named --> DataRecord
    Named --> DataChoice
    Named --> DataArray
    Named --> Matrix
    Named --> DataStream
```

## File dependency graph

How the schema files import each other:

```mermaid
graph LR
    BT["basic_types.*<br/><small>Pkg 1 & 2</small>"]
    SC["scalar_components.*<br/><small>Pkg 3 & 4</small>"]
    GEO["geometry.*<br/><small>Pkg 9</small>"]
    ENC["encodings.*<br/><small>Pkg 10</small>"]
    ROOT["sweCommon3.*<br/><small>Pkg 5–8</small>"]

    SC --> BT
    GEO --> BT
    ENC --> BT
    ROOT --> BT
    ROOT --> SC
    ROOT --> GEO
    ROOT --> ENC
```

`basic_types` is the leaf dependency — everything else imports it. `sweCommon3` (the root file) imports all four sub-schemas.

## Encoding selection flow

How the encoding system connects to data components:

```mermaid
flowchart TD
    DA["DataArray / Matrix / DataStream"]
    ENC{"encoding field"}
    TEXT["TextEncoding<br/><small>CSV-like delimited</small>"]
    JSON["JSONEncoding<br/><small>Objects or arrays</small>"]
    XML["XMLEncoding<br/><small>XML elements</small>"]
    BIN["BinaryEncoding<br/><small>Raw/base64 bytes</small>"]
    VALS["values"]
    INLINE["Inline bytes"]
    EXTERN["External link<br/><small>(AssociationAttributeGroup)</small>"]

    DA --> ENC
    ENC --> TEXT
    ENC --> JSON
    ENC --> XML
    ENC --> BIN
    DA --> VALS
    VALS --> INLINE
    VALS --> EXTERN
```

For `DataStream`, values are always external (the inline option is not available).
