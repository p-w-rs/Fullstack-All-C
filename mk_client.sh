#!/bin/bash

mkdir -p build/webasm

C_VERSION="-std=c17"
CXX_VERSION="-std=c++17"
OPTIMIZATION_FLAGS="-Os"
WARNING_FLAGS="-Wall -Wextra -pedantic -Wshadow -Wformat -Wconversion -Wunused -Wnull-dereference -Wdouble-promotion -Wstrict-prototypes"
EMCC_FLAGS="-s USE_SDL=2 -s USE_SDL_IMAGE=2"

INCLUDE_PATHS="-Ilibs/imgui -Ilibs/imgui/backends -Isrc/shared"

for file in $(find libs/imgui -maxdepth 1 -name "*.cpp"); do
    filename=$(basename -- "$file")
    output="build/webasm/${filename%.cpp}.o"
    em++ $CXX_VERSION $OPTIMIZATION_FLAGS $EMCC_FLAGS $INCLUDE_PATHS $file -c -o $output
done
em++ $CXX_VERSION $OPTIMIZATION_FLAGS $EMCC_FLAGS $INCLUDE_PATHS libs/imgui/backends/imgui_impl_sdl2.cpp -c -o build/webasm/imgui_impl_sdl2.cpp.o
em++ $CXX_VERSION $OPTIMIZATION_FLAGS $EMCC_FLAGS $INCLUDE_PATHS libs/imgui/backends/imgui_impl_sdlrenderer2.cpp -c -o build/webasm/imgui_impl_sdlrenderer2.cpp.o

for folder in src/shared src/client; do
    for file in $(find $folder -name "*.cpp"); do
        filename=$(basename -- "$file")
        output="build/webasm/${filename%.cpp}.o"
        em++ $CXX_VERSION $OPTIMIZATION_FLAGS $WARNING_FLAGS $EMCC_FLAGS $INCLUDE_PATHS -c $file -o $output
    done
done

em++ $CXX_VERSION $OPTIMIZATION_FLAGS $WARNING_FLAGS $EMCC_FLAGS $INCLUDE_PATHS build/webasm/*.o -o static/index.html --shell-file static/template.html

