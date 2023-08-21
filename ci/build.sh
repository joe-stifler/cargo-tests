#!/bin/bash
set -eou pipefail

export PATH=$PATH:/usr/local/cargo/bin/

mkdir -p bin/

# Compile the C code into an object file
gcc -c -fPIC src/api.c -o bin/api.o

# Create a shared library from the object file
gcc -shared bin/api.o -o bin/libapi.so

INCLUDE_FILE="api"
INCLUDE_PATH="src"
LIB_PATH="test-sys"
RUST_PATH="$(pwd)/rust"
RUST_INCLUDE_NAME="bindings.rs"
bindgen --allowlist-file ${INCLUDE_PATH}/${INCLUDE_FILE}.h ${INCLUDE_PATH}/${INCLUDE_FILE}.h -o ${RUST_PATH}/${LIB_PATH}/src/${RUST_INCLUDE_NAME}

SO_LIB_PATH=$1
NEW_VERSION=$2

echo "Hellow World: $SO_LIB_PATH"

cp bin/libapi.so ${SO_LIB_PATH}

sed -i 's/version = "*.*.*" # DO NOT CHANGE/version = "'${NEW_VERSION}'" # DO NOT CHANGE/' ${RUST_PATH}/${LIB_PATH}/Cargo.toml

