#!/bin/bash

REPO_DIR=$GITHUB_WORKSPACE
BUILD_DIR=build
INSTALL_DIR=install

if [[ $(awk -F= '/^ID=/ {print $2}' /etc/os-release) == "alpine" ]]; then
  CMAKE_OPTS+=( "-DMUSL=ON" )
fi
if [[ "$STANDALONE" == "true" ]]; then
  CMAKE_OPTS+=( "-DUSEWX=no" )
fi
if [[ "$ARCH" =~ ^(x86|armhf|armv7)$ ]]; then
  # CMAKE_OPTS+=( "-DNETROCKS=no" )
  echo "patch for x86, armhf and armv7 ..."
  pwd
  sed -ibak 's|const size_t piece = std::min(len - rv, _chunk);|size_t piece = 0; if (len - rv <= _chunk) { piece = len -rv; } if (len - rv > _chunk) { piece = _chunk; }|' ./NetRocks/src/Protocol/SHELL/ProtocolSHELL.cpp
fi
if [[ "$PLUGINS_EXTRA" == "true" ]]; then
  for plug in netcfgplugin sqlplugin processes ; do
    git clone --depth 1 https://github.com/VPROFi/$plug.git && \
    ( cd $plug && \
      find . -mindepth 1 -name 'src' -prune -o -exec rm -rf {} + && \
      mv src/* . && rm -rf src )
    echo "add_subdirectory($plug)" >> CMakeLists.txt
  done
fi
if [[ "$PLUGINS" == "false" ]]; then
  CMAKE_OPTS+=( "-DCOLORER=no -DNETROCKS=no -DALIGN=no -DAUTOWRAP=no -DCALC=no \
    -DCOMPARE=no -DDRAWLINE=no -DEDITCASE=no -DEDITORCOMP=no -DFILECASE=no \
    -DINCSRCH=no -DINSIDE=no -DMULTIARC=no -DSIMPLEINDENT=no -DTMPPANEL=no" )
fi

QUILT_PATCHES=$REPO_DIR/patches quilt push -a

mkdir -p $BUILD_DIR && cd $BUILD_DIR && \
cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DCMAKE_C_COMPILER_LAUNCHER=/usr/bin/ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=/usr/bin/ccache \
  -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON \
  -DGIT_HASH=$SHA \
  ${CMAKE_OPTS[@]} .. && \
  ninja && ninja install && \

find $REPO_DIR -type d -path "*/AppDir" -exec tar cJvf far2l.tar.xz -C {} . \;

if [[ "$STANDALONE" == "true" ]]; then
  ( cd $INSTALL_DIR && ./far2l --help >/dev/null && bash -x $REPO_DIR/make_standalone.sh ) && \
  makeself --keep-umask $REPO_DIR/far2l/$BUILD_DIR/$INSTALL_DIR $PKG_NAME.run "FAR2L File Manager" ./far2l && \
  find $REPO_DIR -type f -name "$PKG_NAME.run" -exec bash -c "tar cvf ${PKG_NAME/${VERSION}_}.run.tar --transform 's|.*/||' {}" \;
  ( cd $INSTALL_DIR && ./far2l --help )
fi

if [[ "$APPIMAGE" == "true" ]]; then
  export DISABLE_COPYRIGHT_FILES_DEPLOYMENT=1
  export NO_STRIP=1
  # export APPIMAGE_EXTRACT_AND_RUN=1
  export ARCH=$(uname -m)
  ( cd $REPO_DIR && \
    AppDir/usr/bin/far2l --help >/dev/null && \
    sed 's|@APP@|far2l|' -i AppRun && cp -vf AppRun AppDir && chmod +x AppDir/AppRun && \
    wget --no-check-certificate https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-$ARCH.AppImage && \
    wget --no-check-certificate https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$ARCH.AppImage && \
    chmod +x *.AppImage && \
    ./linuxdeploy-*.AppImage --appdir AppDir && \
    ./appimagetool-*.AppImage -v AppDir $PKG_NAME.AppImage )
  find $REPO_DIR -type f -name "$PKG_NAME.AppImage" -exec bash -c "tar cvf ${PKG_NAME/${VERSION}_}.AppImage.tar --transform 's|.*/||' {}" \;
fi

ccache --max-size=50M --show-stats
