#!/bin/bash

# Set the required environment variables
# You should replace these placeholder values with the actual addresses
export EMITTER_ADDRESS="DPL1CzU6YcYeyC9Qr12UFsZKkEW9xkwBGu3uxbSCU1SV"
export BRIDGE_ADDRESS="EEesMj628MosfFKiR8JpjZaS4b8uoK9cVh8tH3utzRPP"

# Build Wormhole Solana programs
cargo build-bpf --manifest-path "bridge/program/Cargo.toml" -- --locked
cargo build-bpf --manifest-path "bridge/cpi_poster/Cargo.toml" -- --locked
cargo build-bpf --manifest-path "modules/token_bridge/program/Cargo.toml" -- --locked
cargo build-bpf --manifest-path "modules/nft_bridge/program/Cargo.toml" -- --locked
cargo build-bpf --manifest-path "migration/Cargo.toml" -- --locked

# Create destination directory if it doesn't exist
mkdir -p deps

# Copy the compiled programs
cp target/deploy/bridge.so deps/bridge.so
cp target/deploy/cpi_poster.so deps/cpi_poster.so
cp target/deploy/wormhole_migration.so deps/wormhole_migration.so
cp target/deploy/token_bridge.so deps/token_bridge.so
cp target/deploy/nft_bridge.so deps/nft_bridge.so
cp external/mpl_token_metadata.so deps/mpl_token_metadata.so

# Unset the environment variables after use
unset EMITTER_ADDRESS
unset BRIDGE_ADDRESS