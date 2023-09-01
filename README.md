[![build](https://github.com/spvkgn/far2l-portable/actions/workflows/build.yml/badge.svg)](https://github.com/spvkgn/far2l-portable/actions/workflows/build.yml) ![version](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/spvkgn/f53cb6c1d56b0eaf40c88d607fc5fef1/raw/far2l-portable.json)
# [FAR2L](https://github.com/elfmz/far2l) File Manager portable | AppImage
## Download and run
### Self-extractable tar-archive
with TTY X/Xi backend
* built on Alpine | ~20 MB (x86_64 x86 aarch64 armhf armv7 ppc64le s390x)
```shell
wget -qO- https://api.github.com/repos/spvkgn/far2l-portable/releases/latest | \
grep -Po "browser_download_url\": \"\K.*$(uname -m).run.tar(?=\")" | wget -qi- -O- | \
tar -xv -C /tmp && /tmp/far2l_*.run
```
* built on Ubuntu 16.04 | ~30 MB (x86_64 only)
```shell
wget -qO- https://api.github.com/repos/spvkgn/far2l-portable/releases/latest | \
grep -Po "browser_download_url\": \"\K.*$(uname -m)-glibc.run.tar(?=\")" | wget -qi- -O- | \
tar -xv -C /tmp && /tmp/far2l_*.run
```
### AppImage
with wx-GUI and TTY X/Xi backend
* built on Ubuntu 20.04 | ~45 MB (x86_64 only)
```shell
wget -qO- https://api.github.com/repos/spvkgn/far2l-portable/releases/latest | \
grep -Po "browser_download_url\": \"\K.*$(uname -m).AppImage.tar(?=\")" | wget -qi- -O- | \
tar -xv -C /tmp && /tmp/far2l_*.AppImage
```
Or get the binary in [Releases](https://github.com/spvkgn/far2l-portable/releases)
