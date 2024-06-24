#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

patch -p1 <${PROJECT_DIR}/patches/libsrt-remove-brew-dep.patch

cp ${PROJECT_DIR}/scripts/libsrt/meson.build ./meson.build
meson setup build \
	--cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
	--prefix="${OUTPUT_DIR}"

meson compile -C build libsrt

# manual install to preserve symlinks (meson install -C build)
mkdir -p "${OUTPUT_DIR}"
cp -R build/dist"${OUTPUT_DIR}"/* "${OUTPUT_DIR}"/
