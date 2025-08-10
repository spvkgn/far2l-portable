#!/bin/bash
set -eo pipefail

REPO_DIR=$GITHUB_WORKSPACE
export CCACHE_DIR=$REPO_DIR/.ccache
export DESTDIR=$REPO_DIR/AppDir
BUILD_DIR=build

if [[ $(awk -F= '/^ID=/ {print $2}' /etc/os-release) == "alpine" ]]; then
  CMAKE_OPTS+=( "-DMUSL=ON -DARCLITE=no" )
fi
if [[ "$WXGUI" == "false" ]]; then
  CMAKE_OPTS+=( "-DUSEWX=no" )
fi
if [[ "$PLUGINS_EXTRA" == "true" ]]; then
  ( cd $REPO_DIR/far2l
    for plug in netcfgplugin sqlplugin processes ; do
      git clone --depth 1 https://github.com/VPROFi/$plug.git
      ( cd $plug
        find . -mindepth 1 -name 'src' -prune -o -exec rm -rf {} +
        mv src/* . && rm -rf src )
      echo "add_subdirectory($plug)" >> CMakeLists.txt
    done )
fi
if [[ "$PLUGINS" == "false" ]]; then
  CMAKE_OPTS+=( "-DARCLITE=no -DCOLORER=no -DNETROCKS=no -DALIGN=no -DAUTOWRAP=no -DCALC=no \
    -DCOMPARE=no -DDRAWLINE=no -DEDITCASE=no -DEDITORCOMP=no -DFILECASE=no \
    -DINCSRCH=no -DINSIDE=no -DMULTIARC=no -DSIMPLEINDENT=no -DTMPPANEL=no" )
fi

[[ -d $REPO_DIR/patches ]] && ( cd $REPO_DIR/far2l && QUILT_PATCHES=$REPO_DIR/patches quilt push -a )

mkdir -p $BUILD_DIR
cmake -S $REPO_DIR/far2l -B$REPO_DIR/far2l/$BUILD_DIR \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  ${CMAKE_OPTS[@]}
  cmake --build $REPO_DIR/far2l/$BUILD_DIR --target install/strip -- -j$(nproc)

if [[ "$STANDALONE" == "true" ]]; then
  mkdir -p $REPO_DIR/standalone
  cp -a $REPO_DIR/far2l/$BUILD_DIR/install/* $REPO_DIR/standalone
  if [[ "$ADD_7Z" == "true" ]]; then
    cp -a /usr/lib/7zip/7z.so $REPO_DIR/standalone
  fi
  ( cd "$REPO_DIR/standalone"
    ./far2l --help >/dev/null
    bash -x "$REPO_DIR/make_standalone.sh"
    if [[ "$ADD_7Z" == "true" ]]; then
      mv 7z.so lib
      ln -s ../../../lib/7z.so Plugins/arclite/plug/7z.so
    fi )
  makeself --keep-umask --nomd5 --nocrc $REPO_DIR/standalone $PKG_NAME.run "FAR2L File Manager" ./far2l
  tar -cvf ${PKG_NAME/_${VERSION}}.run.tar $PKG_NAME.run
fi

tar -cJvf $REPO_DIR/far2l.tar.xz -C $REPO_DIR/AppDir .

ccache --max-size=50M --show-stats
