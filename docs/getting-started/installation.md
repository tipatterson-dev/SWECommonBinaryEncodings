# Installation

This page covers installing the schema compilers and generating language bindings from the schemas.

## Prerequisites

You need at least one of the three schema compilers installed. Install only the ones you plan to use.

### Cap'n Proto

=== "macOS"

    ```sh
    brew install capnp
    ```

=== "Ubuntu / Debian"

    ```sh
    sudo apt-get install capnproto libcapnp-dev
    ```

=== "From source"

    ```sh
    curl -O https://capnproto.org/capnproto-c++-1.0.2.tar.gz
    tar zxf capnproto-c++-1.0.2.tar.gz
    cd capnproto-c++-1.0.2
    ./configure && make -j$(nproc) && sudo make install
    ```

### FlatBuffers

=== "macOS"

    ```sh
    brew install flatbuffers
    ```

=== "Ubuntu / Debian"

    ```sh
    sudo apt-get install flatbuffers-compiler
    ```

=== "From source"

    ```sh
    git clone https://github.com/google/flatbuffers.git
    cd flatbuffers && cmake -G "Unix Makefiles" && make && sudo make install
    ```

### Protocol Buffers

=== "macOS"

    ```sh
    brew install protobuf
    ```

=== "Ubuntu / Debian"

    ```sh
    sudo apt-get install protobuf-compiler libprotobuf-dev
    ```

## Generating code

Clone the repository and use the Makefile:

```sh
git clone https://github.com/tipatterson-dev/SWECommonBinaryEncodings.git
cd SWECommonBinaryEncodings
```

Build all three at once:

```sh
make all
```

Or build individually:

```sh
make capnproto     # → gen/capnproto/
make flatbuffers   # → gen/flatbuffers/
make protobuf      # → gen/protobuf/
```

Generated code is written to `gen/<format>/`.

### Choosing a target language

The Makefile defaults to C++. Override with variables:

```sh
# Cap'n Proto — Java
make capnproto CAPNP_LANG=java

# FlatBuffers — Python
make flatbuffers FLATC_LANG=python

# Protocol Buffers — Go
make protobuf PROTO_LANG=go
```

### Direct compiler invocation

If you prefer not to use the Makefile:

=== "Cap'n Proto"

    ```sh
    capnp compile -oc++:gen/capnproto --src-prefix=capnproto capnproto/sweCommon3.capnp
    ```

=== "FlatBuffers"

    ```sh
    flatc --cpp -o gen/flatbuffers flatbuffers/sweCommon3.fbs
    ```

=== "Protocol Buffers"

    ```sh
    protoc --cpp_out=gen/protobuf --proto_path=protobuf protobuf/sweCommon3.proto
    ```

## Cleaning generated files

```sh
make clean    # removes the entire gen/ directory
```
