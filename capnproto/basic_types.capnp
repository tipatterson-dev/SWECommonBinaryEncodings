# OGC SWE Common Data Model 3.0 — Cap'n Proto Schema — Basic Types
# Packages 1 & 2: value types and abstract data component hierarchy.
# Standard: OGC 24-014  (https://docs.ogc.org/is/24-014/24-014.html)

@0xe0ea178c89fbad99;


# ═══════════════════════════════════════════════════════════════════════════
# Package 1 — Basic Types
# ═══════════════════════════════════════════════════════════════════════════

struct AbstractSWE {
  # Base for all SWE Common objects other than value objects.
  id          @0 :Text;   # optional — referenceable via URI fragment
}

struct AbstractSWEIdentifiable {
  # Base for objects with human-readable identification metadata.
  base        @0 :AbstractSWE;
  label       @1 :Text;        # short human-readable name
  description @2 :Text;        # longer human-readable description
}

struct UnitReference {
  # Reference to a unit of measure — either by UCUM code or by URI.
  label       @0 :Text;        # human-readable unit label
  symbol      @1 :Text;        # preferred display symbol
  code        @2 :Text;        # UCUM code
  href        @3 :Text;        # URI to unit definition
}

struct NumberOrSpecial {
  # A numeric value, or a special IEEE-754 sentinel.
  union {
    number    @0 :Float64;
    nan       @1 :Void;
    posInf    @2 :Void;        # +Infinity
    negInf    @3 :Void;        # -Infinity
  }
}

struct DateTimeOrNumber {
  # ISO-8601 date-time string, or a numeric / special value.
  union {
    dateTime  @0 :Text;        # ISO-8601 encoded
    number    @1 :Float64;
    nan       @2 :Void;
    posInf    @3 :Void;
    negInf    @4 :Void;
  }
}

# ── Nil values ──────────────────────────────────────────────────────────

struct NilValueText {
  reason      @0 :Text;        # URI — reason for the nil sentinel
  value       @1 :Text;
}

struct NilValueInteger {
  reason      @0 :Text;
  value       @1 :Int64;
}

struct NilValueNumber {
  reason      @0 :Text;
  value       @1 :NumberOrSpecial;
}

struct NilValueTime {
  reason      @0 :Text;
  value       @1 :DateTimeOrNumber;
}

# ── Constraints ─────────────────────────────────────────────────────────

struct AllowedValues {
  # Permitted numeric values — enumeration and/or inclusive intervals.
  values             @0 :List(NumberOrSpecial);
  intervals          @1 :List(NumberInterval);
  significantFigures @2 :UInt8;    # 1..40; 0 means unset

  struct NumberInterval {
    low  @0 :NumberOrSpecial;
    high @1 :NumberOrSpecial;
  }
}

struct AllowedTokens {
  # Permitted string values — enumeration or regex pattern.
  union {
    values  @0 :List(Text);
    pattern @1 :Text;      # regex
  }
}

struct AllowedTimes {
  # Permitted temporal values — enumeration and/or inclusive intervals.
  values             @0 :List(DateTimeOrNumber);
  intervals          @1 :List(TimeInterval);
  significantFigures @2 :UInt8;

  struct TimeInterval {
    low  @0 :DateTimeOrNumber;
    high @1 :DateTimeOrNumber;
  }
}

# ── Soft-named property & associations ──────────────────────────────────

struct SoftNamedProperty {
  # A name token that follows the pattern [A-Za-z][A-Za-z0-9_-]*
  name @0 :Text;
}

struct AssociationAttributeGroup {
  # XLink-style by-reference association.
  href    @0 :Text;      # URI-reference  (required)
  role    @1 :Text;      # URI
  arcrole @2 :Text;      # URI
  title   @3 :Text;
}


# ═══════════════════════════════════════════════════════════════════════════
# Package 2 — Abstract Data Component hierarchy
# ═══════════════════════════════════════════════════════════════════════════

struct AbstractDataComponent {
  # Common metadata carried by every data component.
  identifiable @0 :AbstractSWEIdentifiable;
  updatable    @1 :Bool;   # can value change externally?
  optional     @2 :Bool;   # can data be omitted in stream?
  definition   @3 :Text;   # URI — semantic link
}

struct AbstractSimpleComponent {
  # Additional metadata for scalar / range components.
  dataComponent  @0 :AbstractDataComponent;
  referenceFrame @1 :Text;   # URI-reference — CRS / temporal frame
  axisID         @2 :Text;   # CRS axis identifier
}
