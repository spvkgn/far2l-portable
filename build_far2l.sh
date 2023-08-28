#!/bin/bash

BUILD_DIR=build
INSTALL_DIR=install
PLUGINS=

if [[ $(awk -F= '/^ID=/ {print $2}' /etc/os-release) == "alpine" ]]; then
  CMAKE_OPTS+=( "-DCMAKE_MAKE_PROGRAM=/usr/lib/ninja-build/bin/ninja -DMUSL=ON" )
fi
if [[ "$PLUGINS" == "OFF" ]]; then
  CMAKE_OPTS+=( "-DCOLORER=no -DNETROCKS=no -DALIGN=no -DAUTOWRAP=no -DCALC=no \
    -DCOMPARE=no -DDRAWLINE=no -DEDITCASE=no -DEDITORCOMP=no -DFILECASE=no \
    -DINCSRCH=no -DINSIDE=no -DMULTIARC=no -DSIMPLEINDENT=no -DTMPPANEL=no" )
fi

QUILT_PATCHES=../patches quilt push -a

mkdir -p $BUILD_DIR && cd $BUILD_DIR && \
cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DCMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache \
  -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON -DGIT_HASH=$SHA \
  -DUSEWX=no ${CMAKE_OPTS[@]} .. && cmake --build . && \

find ${GITHUB_WORKSPACE} -type d -path "*/$BUILD_DIR/$INSTALL_DIR" -exec tar cJvf far2l.tar.xz -C {} . \; && \
echo "PATH_TARXZ=$(find ${GITHUB_WORKSPACE} -type f -name 'far2l.tar*' -print)" >> $GITHUB_ENV && \

( cd $INSTALL_DIR && bash ${GITHUB_WORKSPACE}/make_standalone.sh ) && \
makeself --keep-umask ${GITHUB_WORKSPACE}/far2l/$BUILD_DIR/$INSTALL_DIR $PKG_NAME.run "FAR2L File Manager" ./far2l && \

find ${GITHUB_WORKSPACE} -type f -name '*.run' -exec sh -c 'tar cvf $PKG_NAME.run.tar --transform "s|.*/||" {}' \; && \
echo "PATH_RUNTAR=$(find ${GITHUB_WORKSPACE} -type f -name '*.run.tar' -print)" >> $GITHUB_ENV

( cd $INSTALL_DIR && ./far2l --help )
ccache -s
