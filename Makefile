SHELL = /usr/bin/env bash
MAKEFLAGS += --no-builtin-rules

PREFIX ?= /usr/local
OUT = build
BIN = $(OUT)/bin

-include Makefile.help

# Hardcode the version string
VERSION = v1.0.0

.PHONY: dirs
dirs: Makefile
	@mkdir -p $(BIN)

.PHONY: install
## Install guardiand binary
install:
	install -m 775 $(BIN)/* $(PREFIX)/bin
	setcap cap_ipc_lock=+ep $(PREFIX)/bin/guardiand

.PHONY: generate
generate: dirs
	cd tools && ./build.sh
	rm -rf bridge
	rm -rf node/pkg/proto
	tools/bin/buf generate

.PHONY: node
## Build guardiand binary
node: $(BIN)/guardiand

.PHONY: $(BIN)/guardiand
$(BIN)/guardiand: CGO_ENABLED=1
$(BIN)/guardiand: dirs generate
	@# The go-ethereum and celo-blockchain packages both implement secp256k1 using the exact same header, but that causes duplicate symbols.
	cd node && go build -ldflags "-X github.com/dain-protocol/wormhole/node/pkg/version.version=${VERSION} -extldflags -Wl,--allow-multiple-definition" \
	  -mod=readonly -o ../$(BIN)/guardiand \
	  github.com/dain-protocol/wormhole/node

.PHONY: clean
## Clean build directory
clean:
	rm -rf $(OUT)
