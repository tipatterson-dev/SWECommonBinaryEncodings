# OGC SWE Common Data Model 3.0 — Cap'n Proto Schema — Geometry Components
# Package 9: ISO-19107 geometry components (new in SWE Common 3.0).
# Standard: OGC 24-014  (https://docs.ogc.org/is/24-014/24-014.html)

@0x8343601ff242e2db;

using BT = import "basic_types.capnp";


# ═══════════════════════════════════════════════════════════════════════════
# Package 9 — Geometry Components  (new in SWE Common 3.0)
# ═══════════════════════════════════════════════════════════════════════════

enum GeometryType {
  # ISO-19107 / GeoJSON geometry type constraints.
  point           @0;
  multiPoint      @1;
  lineString      @2;
  multiLineString @3;
  polygon         @4;
  multiPolygon    @5;
}

struct GeoJsonGeometry {
  # Simplified GeoJSON Geometry representation for wire use.
  # Coordinates are stored as a flat Data blob of packed Float64; the
  # nesting structure is defined by the geometry type.
  type            @0 :GeometryType;
  coordinates     @1 :Data;    # packed float64 coordinate data
  coordinatesJson @2 :Text;    # full GeoJSON coordinates as text fallback
}

struct GeometryConstraint {
  geomTypes @0 :List(GeometryType);
}

struct Geometry {
  # ISO-19107 geometry embedded in a SWE Common data structure.
  dataComponent @0 :BT.AbstractDataComponent;
  constraint    @1 :GeometryConstraint;
  nilValues     @2 :List(BT.NilValueText);
  srs           @3 :Text;           # URI — coordinate reference system
  value         @4 :GeoJsonGeometry;
}