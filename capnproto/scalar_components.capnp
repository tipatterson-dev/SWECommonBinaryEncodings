# OGC SWE Common Data Model 3.0 — Cap'n Proto Schema — Scalar & Range Components
# Packages 3 & 4: simple scalar components and their range counterparts.
# Standard: OGC 24-014  (https://docs.ogc.org/is/24-014/24-014.html)

@0xc357dbe7f46adba5;

using BT = import "basic_types.capnp";


# ═══════════════════════════════════════════════════════════════════════════
# Package 3 — Simple (Scalar) Components
# ═══════════════════════════════════════════════════════════════════════════

struct Boolean {
  # Truth value: true / false.
  base  @0 :BT.AbstractSimpleComponent;
  value @1 :Bool;
}

struct Count {
  # Discrete counting value (integer representation).
  base       @0 :BT.AbstractSimpleComponent;
  constraint @1 :BT.AllowedValues;
  nilValues  @2 :List(BT.NilValueInteger);
  value      @3 :Int64;
}

struct Quantity {
  # Continuous measured value with a unit of measure.
  base       @0 :BT.AbstractSimpleComponent;
  uom        @1 :BT.UnitReference;           # required
  constraint @2 :BT.AllowedValues;
  nilValues  @3 :List(BT.NilValueNumber);
  value      @4 :BT.NumberOrSpecial;
}

struct Text {
  # Free-form textual value.
  base       @0 :BT.AbstractSimpleComponent;
  constraint @1 :BT.AllowedTokens;
  nilValues  @2 :List(BT.NilValueText);
  value      @3 :Text;
}

struct Category {
  # Token from a controlled vocabulary / code space.
  base       @0 :BT.AbstractSimpleComponent;
  codeSpace  @1 :Text;                    # URI to dictionary
  constraint @2 :BT.AllowedTokens;
  nilValues  @3 :List(BT.NilValueText);
  value      @4 :Text;
}

struct Time {
  # Temporal instant — ISO-8601 or numeric offset from a reference epoch.
  base          @0 :BT.AbstractSimpleComponent;
  referenceTime @1 :Text;                 # ISO-8601 epoch origin
  localFrame    @2 :Text;                 # URI — local temporal frame
  uom           @3 :BT.UnitReference;     # required
  constraint    @4 :BT.AllowedTimes;
  nilValues     @5 :List(BT.NilValueTime);
  value         @6 :BT.DateTimeOrNumber;
}


# ═══════════════════════════════════════════════════════════════════════════
# Package 4 — Range Components
# ═══════════════════════════════════════════════════════════════════════════

struct CountRange {
  base       @0 :BT.AbstractSimpleComponent;
  constraint @1 :BT.AllowedValues;
  nilValues  @2 :List(BT.NilValueInteger);
  low        @3 :Int64;
  high       @4 :Int64;
}

struct QuantityRange {
  base       @0 :BT.AbstractSimpleComponent;
  uom        @1 :BT.UnitReference;
  constraint @2 :BT.AllowedValues;
  nilValues  @3 :List(BT.NilValueNumber);
  low        @4 :BT.NumberOrSpecial;
  high       @5 :BT.NumberOrSpecial;
}

struct TimeRange {
  base          @0 :BT.AbstractSimpleComponent;
  referenceTime @1 :Text;
  localFrame    @2 :Text;
  uom           @3 :BT.UnitReference;
  constraint    @4 :BT.AllowedTimes;
  nilValues     @5 :List(BT.NilValueTime);
  low           @6 :BT.DateTimeOrNumber;
  high          @7 :BT.DateTimeOrNumber;
}

struct CategoryRange {
  base       @0 :BT.AbstractSimpleComponent;
  codeSpace  @1 :Text;
  constraint @2 :BT.AllowedTokens;
  nilValues  @3 :List(BT.NilValueText);
  low        @4 :Text;
  high       @5 :Text;
}