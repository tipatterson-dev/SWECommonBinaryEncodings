##############################################################################
# OGC SWE Common Data Model 3.0 — Cap'n Proto Schema
# Standard: OGC 24-014  (https://docs.ogc.org/is/24-014/24-014.html)
#
# Root file: composite component types (Packages 5–8).  The four independent
# sub-schemas are imported below:
#
#   basic_types.capnp       — Packages 1 & 2  (value types, abstract bases)
#   scalar_components.capnp — Packages 3 & 4  (scalar and range components)
#   geometry.capnp          — Package 9        (ISO-19107 geometry)
#   encodings.capnp         — Package 10       (text, JSON, XML, binary)
#
# Packages 5–8 are kept together here because AnyComponent, NamedComponent,
# DataRecord, Vector, DataArray, DataChoice, and Matrix form a mutually-
# referential cycle that Cap'n Proto cannot split across files.
#
# Design notes
# ────────────
# • Cap'n Proto has no class inheritance.  Abstract base classes are
#   represented as embedded structs inside every concrete type.
# • OGC polymorphic associations are expressed as unnamed unions.
# • Field ordinals (@0, @1, …) must never be renumbered or reused.
# • The file ID @0xb3a4f7c8e2d19056 must remain stable.
##############################################################################

@0xb3a4f7c8e2d19056;   # unique file ID — must remain stable

using BT  = import "basic_types.capnp";
using SC  = import "scalar_components.capnp";
using GEO = import "geometry.capnp";
using ENC = import "encodings.capnp";


# ═══════════════════════════════════════════════════════════════════════════
# Package 5 — Polymorphic component unions
# ═══════════════════════════════════════════════════════════════════════════

struct AnyScalarComponent {
  union {
    boolean  @0 :SC.Boolean;
    count    @1 :SC.Count;
    quantity @2 :SC.Quantity;
    time     @3 :SC.Time;
    category @4 :SC.Category;
    text     @5 :SC.Text;
  }
}

struct AnySimpleComponent {
  union {
    scalar        @0 :AnyScalarComponent;
    countRange    @1 :SC.CountRange;
    quantityRange @2 :SC.QuantityRange;
    timeRange     @3 :SC.TimeRange;
    categoryRange @4 :SC.CategoryRange;
  }
}

struct AnyComponent {
  # The top-level discriminated union over all concrete component types.
  union {
    boolean       @0  :SC.Boolean;
    count         @1  :SC.Count;
    quantity      @2  :SC.Quantity;
    time          @3  :SC.Time;
    category      @4  :SC.Category;
    text          @5  :SC.Text;
    countRange    @6  :SC.CountRange;
    quantityRange @7  :SC.QuantityRange;
    timeRange     @8  :SC.TimeRange;
    categoryRange @9  :SC.CategoryRange;
    dataRecord    @10 :DataRecord;
    vector        @11 :Vector;
    dataArray     @12 :DataArray;
    matrix        @13 :Matrix;
    dataChoice    @14 :DataChoice;
    geometry      @15 :GEO.Geometry;
  }
}

struct ComponentOrRef {
  # A component can be provided inline or by XLink reference.
  union {
    inline @0 :AnyComponent;
    ref    @1 :BT.AssociationAttributeGroup;
  }
}

struct NamedComponent {
  # A soft-named data component (used in DataRecord fields, etc.).
  name      @0 :Text;           # NameToken
  component @1 :ComponentOrRef;
}


# ═══════════════════════════════════════════════════════════════════════════
# Package 6 — Record Components
# ═══════════════════════════════════════════════════════════════════════════

struct DataRecord {
  # ISO-11404 Record — an ordered sequence of named fields.
  dataComponent @0 :BT.AbstractDataComponent;
  fields        @1 :List(NamedComponent);  # minItems: 1
}

struct Vector {
  # Mathematical vector — list of scalar coordinates in a reference frame.
  dataComponent  @0 :BT.AbstractDataComponent;
  referenceFrame @1 :Text;                 # URI-reference (required)
  localFrame     @2 :Text;                 # URI-reference
  coordinates    @3 :List(NamedCoordinate);

  struct NamedCoordinate {
    name       @0 :Text;
    coordinate @1 :CoordinateComponent;
  }

  struct CoordinateComponent {
    # Coordinates may be Count, Quantity, or Time.
    union {
      count    @0 :SC.Count;
      quantity @1 :SC.Quantity;
      time     @2 :SC.Time;
    }
  }
}


# ═══════════════════════════════════════════════════════════════════════════
# Package 7 — Choice Components
# ═══════════════════════════════════════════════════════════════════════════

struct DataChoice {
  # Disjoint union — one of several named component alternatives.
  dataComponent @0 :BT.AbstractDataComponent;
  choiceValue   @1 :SC.Category;           # discriminator in data stream
  items         @2 :List(NamedComponent);
}


# ═══════════════════════════════════════════════════════════════════════════
# Package 8 — Block Components (Arrays & Streams)
# ═══════════════════════════════════════════════════════════════════════════

struct ElementCount {
  # Size specifier for arrays — inline or referenced.
  base       @0 :BT.AbstractSimpleComponent;
  constraint @1 :BT.AllowedValues;
  value      @2 :Int64;
}

struct ElementCountOrRef {
  union {
    inline @0 :ElementCount;
    ref    @1 :BT.AssociationAttributeGroup;
  }
}

struct EncodedValues {
  # Block of encoded values — inline payload or external link.
  union {
    inlineArray @0 :Data;                        # opaque encoded payload
    ref         @1 :BT.AssociationAttributeGroup;
  }
}

struct DataArray {
  # ISO-11404 Array — homogeneous collection of identically-typed elements.
  dataComponent @0 :BT.AbstractDataComponent;
  elementCount  @1 :ElementCountOrRef;
  elementType   @2 :NamedComponent;
  encoding      @3 :ENC.AnyEncoding;
  values        @4 :EncodedValues;
}

struct Matrix {
  # Specialisation of DataArray that carries a reference frame
  # (e.g. for rotation matrices or affine transforms).
  dataComponent  @0 :BT.AbstractDataComponent;
  elementCount   @1 :ElementCountOrRef;
  elementType    @2 :NamedComponent;
  encoding       @3 :ENC.AnyEncoding;
  values         @4 :EncodedValues;
  referenceFrame @5 :Text;                 # URI-reference
  localFrame     @6 :Text;                 # URI-reference
}

struct DataStream {
  # Descriptor for a stream of identically-structured observation records.
  # Note: extends AbstractSWEIdentifiable, NOT AbstractDataComponent.
  identifiable @0 :BT.AbstractSWEIdentifiable;
  elementType  @1 :NamedComponent;                 # required
  encoding     @2 :ENC.AnyEncoding;               # required
  values       @3 :BT.AssociationAttributeGroup;  # out-of-band link
}
