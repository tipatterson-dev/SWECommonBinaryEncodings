CAPNP_LANG  ?= c++
FLATC_LANG  ?= cpp
PROTO_LANG  ?= cpp

CAPNP_SRC   = capnproto/sweCommon3.capnp
FBS_SRC     = flatbuffers/sweCommon3.fbs
PROTO_SRC   = protobuf/sweCommon3.proto

CAPNP_OUT   = gen/capnproto
FBS_OUT     = gen/flatbuffers
PROTO_OUT   = gen/protobuf

.PHONY: all capnproto flatbuffers protobuf clean

all: capnproto flatbuffers protobuf

capnproto: $(CAPNP_OUT)
	capnp compile -o$(CAPNP_LANG):$(CAPNP_OUT) --src-prefix=capnproto $(CAPNP_SRC)

flatbuffers: $(FBS_OUT)
	flatc --$(FLATC_LANG) -o $(FBS_OUT) $(FBS_SRC)

protobuf: $(PROTO_OUT)
	protoc --$(PROTO_LANG)_out=$(PROTO_OUT) --proto_path=protobuf $(PROTO_SRC)

$(CAPNP_OUT) $(FBS_OUT) $(PROTO_OUT):
	mkdir -p $@

clean:
	rm -rf gen/
