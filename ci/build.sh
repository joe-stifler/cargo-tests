#!/bin/bash
set -eou pipefail

export PATH=$PATH:/usr/local/cargo/bin/

mkdir -p bin/

# compile the C code into an object file
gcc -c -fPIC src/api.c -o bin/api.o

# create a shared library from the object file
gcc -shared bin/api.o -o bin/libapi.so

INCLUDE_FILE="api"
INCLUDE_PATH="src"
LIB_PATH="test-sys"
RUST_PATH="$(pwd)/rust"
RUST_INCLUDE_NAME="bindings.rs"
bindgen --allowlist-file ${INCLUDE_PATH}/${INCLUDE_FILE}.h ${INCLUDE_PATH}/${INCLUDE_FILE}.h -o ${RUST_PATH}/${LIB_PATH}/src/${RUST_INCLUDE_NAME}

SO_LIB_PATH=$1
NEW_VERSION=$2

if ! cmp -s bin/libapi.so ${SO_LIB_PATH}; then
    cp bin/libapi.so ${SO_LIB_PATH}
fi

sed -i 's/version = "*.*.*" # DO NOT CHANGE/version = "'${NEW_VERSION}'" # DO NOT CHANGE/' ${RUST_PATH}/${LIB_PATH}/Cargo.toml

if [ "$#" -eq 3 ]; then
    if [[ $3 == "--with-release" ]]
    then
        DIST_PATH="$(pwd)/dist"
        NEW_INCLUDE_NAME="${INCLUDE_FILE}_v${NEW_VERSION}.h"

        mkdir -p ${DIST_PATH}
        cp -f $SO_LIB_PATH ${DIST_PATH}/$(basename "$SO_LIB_PATH")
        cp -f ${INCLUDE_PATH}/${INCLUDE_FILE}.h ${DIST_PATH}/${INCLUDE_FILE}.h

        cd ${RUST_PATH}/${LIB_PATH}
        cargo clean
        cd ..
        zip -r ${DIST_PATH}/test-sys-v${NEW_VERSION}.zip ${LIB_PATH}
        tar -czvf ${DIST_PATH}/test-sys-v${NEW_VERSION}.tar.gz ${LIB_PATH}
    fi
fi
