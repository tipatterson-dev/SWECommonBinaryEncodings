# OGC SWE Common 3.0 — Binary Encodings

Binary serialization schemas for the [OGC SWE Common Data Model 3.0](https://docs.ogc.org/is/24-014/24-014.html) (standard OGC 24-014) in three formats:

| Format | Directory | Root schema |
|--------|-----------|-------------|
| Cap'n Proto | `capnproto/` | `sweCommon3.capnp` |
| FlatBuffers | `flatbuffers/` | `sweCommon3.fbs` |
| Protocol Buffers | `protobuf/` | `sweCommon3.proto` |

All three schemas cover the same ten packages from the OGC specification and are kept in sync.

## Documentation

Full docs are published at **https://cr31.github.io/BinaryEncodings/**. To browse them locally:

```sh
./docs.sh
```

This installs the dependencies into a virtualenv and starts a live-reloading server at [http://localhost:8000](http://localhost:8000). Edit any file under `docs/` and the browser refreshes automatically.

If you just want a one-off build without the dev server:

```sh
./docs.sh build
```

The static site is written to `site/`.

## Building schemas

You need the compiler for whichever format you want to use (see [Installation](https://cr31.github.io/BinaryEncodings/getting-started/installation/) for setup instructions). Then:

```sh
make all          # build all three
make capnproto    # Cap'n Proto only
make flatbuffers  # FlatBuffers only
make protobuf     # Protocol Buffers only
```

Generated code lands in `gen/<format>/`. Override the target language with:

```sh
make capnproto  CAPNP_LANG=java
make flatbuffers FLATC_LANG=python
make protobuf   PROTO_LANG=go
```

## Project structure

```
capnproto/           Cap'n Proto schemas
flatbuffers/         FlatBuffers schemas
protobuf/            Protocol Buffers schemas
docs/                MkDocs documentation source
gen/                 Generated code (not committed)
Makefile             Schema compilation
mkdocs.yml          Docs site configuration
docs.sh              Docs helper script
```

## License

See [LICENSE](LICENSE) for details.
