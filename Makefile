SHELL = /bin/bash
MAKEFLAGS += --no-builtin-rules

PREFIX ?= $(HOME)/.local
OUT = build
BIN = $(OUT)/bin

-include Makefile.help

# Hardcode the version string
VERSION = v1.0.0

.PHONY: all
all: node

.PHONY: dirs
dirs:
	mkdir -p $(BIN)

.PHONY: install
## Install guardiand binary
install: $(BIN)/guardiand
	install -d $(PREFIX)/bin
	install -m 755 $(BIN)/guardiand $(PREFIX)/bin

.PHONY: generate
generate: dirs
	cd tools && ./build.sh
	rm -rf bridge node/pkg/proto
	tools/bin/buf generate

.PHONY: node
## Build guardiand binary
node: $(BIN)/guardiand

.PHONY: $(BIN)/guardiand
$(BIN)/guardiand: CGO_ENABLED=1
$(BIN)/guardiand: dirs generate
	cd node && go mod tidy
	cd node && go build -buildvcs=false -ldflags "-X github.com/dain-protocol/wormhole/node/pkg/version.version=${VERSION} -extldflags '-Wl,--allow-multiple-definition'" \
	  -o ../$(BIN)/guardiand \
	  github.com/dain-protocol/wormhole/node

.PHONY: clean
## Clean build directory
clean:
	rm -rf $(OUT)

.PHONY: help
## Display this help screen
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'