#!/bin/bash

mkdir -p build/native bin

C_VERSION="-std=c17"
CXX_VERSION="-std=c++17"
OPTIMIZATION_FLAGS="-Ofast -flto -march=native -DRELEASE"
WARNING_FLAGS="-Wall -Wextra -pedantic -Wshadow -Wformat -Wconversion -Wunused -Wnull-dereference -Wdouble-promotion -Wstrict-prototypes"

LIB_MONGOOSE_FLAGS="-O3 -DMG_ENABLE_IPV6=1 -DMG_ARCH=MG_ARCH_UNIX"
LIB_SQLITE_FLAGS="-O3 -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_FTS5=1 -DSQLITE_DEFAULT_MEMSTATUS=0"

INCLUDE_PATHS="-Ilibs/mongoose -Ilibs/sqlite -Isrc/shared"
LINKED_LIBS="-lpthread"

for file in $(find libs/mongoose -name "*.c"); do
    filename=$(basename -- "$file")
    output="build/native/${filename%.c}.o"
    clang $C_VERSION $LIB_MONGOOSE_FLAGS -c $file -o $output
done

for file in $(find libs/sqlite -name "*.c"); do
    filename=$(basename -- "$file")
    output="build/native/${filename%.c}.o"
    clang $C_VERSION $LIB_SQLITE_FLAGS -c $file -o $output
done

for folder in src/shared src/server; do
    for file in $(find $folder -name "*.cpp"); do
        filename=$(basename -- "$file")
        output="build/native/${filename%.cpp}.o"
        clang++ $CXX_VERSION $OPTIMIZATION_FLAGS $WARNING_FLAGS $INCLUDE_PATHS $LINKED_LIBS -c $file -o $output
    done
done

clang++ build/native/*.o -o bin/server.exe

