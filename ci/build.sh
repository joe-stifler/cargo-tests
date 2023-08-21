#!/bin/bash
set -eou pipefail

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

LIB_PATH=$1
VERSION=$2

echo "Hellow World: $LIB_PATH"

cp bin/libapi.so ${LIB_PATH}
