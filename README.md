[![build](https://github.com/spvkgn/far2l-portable/actions/workflows/build.yml/badge.svg)](https://github.com/spvkgn/far2l-portable/actions/workflows/build.yml) [![version](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/spvkgn/f53cb6c1d56b0eaf40c88d607fc5fef1/raw/far2l-portable.json)](https://github.com/spvkgn/far2l-portable/releases/latest)
# [FAR2L](https://github.com/elfmz/far2l) File Manager portable | AppImage
## Download and run
### Self-extractable tar-archive
with TTY X/Xi backend
* built on Alpine | ~20 MB (x86_64 x86 aarch64 armhf armv7)
```
wget -qO- https://github.com/spvkgn/far2l-portable/releases/download/latest/far2l-$(uname -m)-musl.run.tar | tar -xv -C /tmp && /tmp/far2l*.run
```
* built on Ubuntu 20.04 | ~35 MB (x86_64 aarch64)
```
wget -qO- https://github.com/spvkgn/far2l-portable/releases/download/latest/far2l-$(uname -m)-glibc.run.tar | tar -xv -C /tmp && /tmp/far2l*.run
```
### AppImage
with wx-GUI
* built on Ubuntu 22.04 | ~55 MB (x86_64 only)
```
wget -qO- https://github.com/spvkgn/far2l-portable/releases/download/latest/far2l-x86_64.AppImage.tar | tar -xv -C /tmp && /tmp/far2l*.AppImage
```
-----
Or get the binary in [Releases](https://github.com/spvkgn/far2l-portable/releases)
