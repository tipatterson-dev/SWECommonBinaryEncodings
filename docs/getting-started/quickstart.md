# Quick Start

This tutorial walks through creating a simple weather observation `DataRecord` containing a temperature `Quantity` and a timestamp `Time`, then serializing it in each of the three formats.

## The data model

We want to represent this observation:

| Field | Type | Value |
|-------|------|-------|
| `temperature` | Quantity (°C) | 23.5 |
| `timestamp` | Time (ISO-8601) | 2025-06-15T14:30:00Z |

In SWE Common terms, this is a **DataRecord** with two **NamedComponent** fields, each containing a scalar component.

## Cap'n Proto (C++)

After generating C++ code with `make capnproto`:

```cpp
#include "sweCommon3.capnp.h"
#include <capnp/message.h>
#include <capnp/serialize-packed.h>
#include <iostream>

int main() {
    capnp::MallocMessageBuilder message;

    // Build the temperature Quantity
    auto tempBuilder = message.initRoot<Quantity>();
    auto tempBase = tempBuilder.initBase();
    auto tempDC = tempBase.initDataComponent();
    auto tempId = tempDC.initIdentifiable();
    tempId.initBase().setId("temp-001");
    tempId.setLabel("Air Temperature");
    tempDC.setDefinition("http://vocab.nerc.ac.uk/collection/P01/current/TMPSTU01/");

    auto uom = tempBuilder.initUom();
    uom.setCode("Cel");
    uom.setLabel("degrees Celsius");

    // Set the value
    tempBuilder.initValue().setNumber(23.5);

    // Serialize
    auto fd = open("observation.capnp.bin", O_WRONLY | O_CREAT, 0644);
    capnp::writePackedMessageToFd(fd, message);
    close(fd);

    return 0;
}
```

## FlatBuffers (Python)

After generating Python code with `make flatbuffers FLATC_LANG=python`:

```python
import flatbuffers
from ogc.swecommon import (
    DataRecord, NamedComponent, Quantity, AbstractDataComponent,
    AbstractSWEIdentifiable, AbstractSWE, UnitReference,
    AnyComponent, AnyComponentWrapper, ComponentOrRef,
    NumberOrSpecial
)

builder = flatbuffers.Builder(1024)

# Build strings first (FlatBuffers builds bottom-up)
temp_id = builder.CreateString("temp-001")
temp_label = builder.CreateString("Air Temperature")
temp_def = builder.CreateString(
    "http://vocab.nerc.ac.uk/collection/P01/current/TMPSTU01/"
)
uom_code = builder.CreateString("Cel")
uom_label = builder.CreateString("degrees Celsius")
field_name = builder.CreateString("temperature")

# Build the Quantity table
Quantity.Start(builder)
# ... populate fields ...
quantity = Quantity.End(builder)

# Wrap in NamedComponent, then DataRecord
# ... (FlatBuffers requires bottom-up construction)

buf = builder.Output()
with open("observation.fbs.bin", "wb") as f:
    f.write(bytes(buf))
```

## Protocol Buffers (Python)

After generating Python code with `make protobuf PROTO_LANG=python`:

```python
from ogc.swecommon import sweCommon3_pb2 as swe

# Build the temperature Quantity
temp = swe.Quantity()
temp.base.data_component.identifiable.base.id = "temp-001"
temp.base.data_component.identifiable.label = "Air Temperature"
temp.base.data_component.definition = (
    "http://vocab.nerc.ac.uk/collection/P01/current/TMPSTU01/"
)
temp.uom.code = "Cel"
temp.uom.label = "degrees Celsius"
temp.value.number = 23.5

# Build the timestamp
ts = swe.Time()
ts.base.data_component.identifiable.base.id = "ts-001"
ts.base.data_component.identifiable.label = "Observation Time"
ts.uom.code = "http://www.opengis.net/def/uom/ISO-8601/0/Gregorian"
ts.value.date_time = "2025-06-15T14:30:00Z"

# Assemble the DataRecord
record = swe.DataRecord()
record.data_component.identifiable.label = "Weather Observation"

field1 = record.fields.add()
field1.name = "temperature"
field1.component.inline.quantity_component.CopyFrom(temp)

field2 = record.fields.add()
field2.name = "timestamp"
field2.component.inline.time_component.CopyFrom(ts)

# Wrap in the root message
msg = swe.SweCommonMessage()
msg.component.data_record.CopyFrom(record)

# Serialize
with open("observation.pb.bin", "wb") as f:
    f.write(msg.SerializeToString())

print(f"Serialized {len(msg.SerializeToString())} bytes")
```

## What to explore next

- [Conceptual Guide](../guide/overview.md) — understand the full 10-package data model
- [Encoding Comparison](../comparison.md) — see how the three formats differ
- [Type Reference](../reference/types.md) — field-level reference for every type
