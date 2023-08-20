#!/bin/bash

DISTRO=$(awk -F= '/^ID=/ {print $2}' /etc/os-release)
LIB_DIR=lib
RPATH="\$ORIGIN"

case $DISTRO in
    alpine) LIBC=musl;;
    debian|ubuntu) LIBC=glibc;;
    *) echo 'Not supported yet'; exit 1
esac

if [[ $LIBC == "musl" ]]; then
    LD_FILE=$(basename $(readlink -f /$(apk info -qL musl | grep ld-)))
elif [[ $LIBC == "glibc" ]]; then
    # LD_FILE=$(basename $(dpkg -L libc6 | grep 'ld-' | xargs readlink -f | sort -u))
    LD_FILE=$(basename $(ldconfig -p | awk -v var="$(dpkg-architecture -qDEB_BUILD_MULTIARCH)/ld-" '$4 ~ var {print $4}'))
fi

rm -rf $LIB_DIR; mkdir $LIB_DIR
readarray -t files < <(find . -type f -executable -exec sh -c 'file -b {} | grep -q ELF' \; -printf '%P\n')
for file in "${files[@]}"; do
    c=$(awk -F/ '{print NF-1}' <<< $file)
    str=
    if (( $c > 0 )); then
        for (( i=1; i<=$c; i++ )); do str+="/.."; done
    fi
    str+="/$LIB_DIR"
    echo $file
    strip $file
    ldd $file | awk '/=>/ {print $3}' | xargs -I{} cp -vL {} $LIB_DIR
    patchelf --set-rpath $RPATH$str $file
    patchelf --print-interpreter $file >/dev/null 2>&1 && patchelf --set-interpreter ${str#/}/$LD_FILE $file
done

if [[ $LIBC == "glibc" ]]; then
    ldconfig -p | awk '/libnss_compat/ {print $8}' | \
    while read -r line; do cp -vL $(dirname $line)/libnss_* $LIB_DIR; done
fi

for file in $LIB_DIR/*; do
    echo $file
    patchelf --set-rpath $RPATH $file
    patchelf --print-interpreter $file >/dev/null 2>&1 && patchelf --set-interpreter $LD_FILE $file
done

if [[ $LIBC == "musl" ]]; then
    apk info -qL musl | xargs -I{} cp -va /{} $LIB_DIR
elif [[ $LIBC == "glibc" ]]; then
    # cp -vL $(dpkg -L libc6 | grep 'ld-' | xargs readlink -f | sort -u) $LIB_DIR
    cp -vL $(ldconfig -p | awk -v var="$(dpkg-architecture -qDEB_BUILD_MULTIARCH)/ld-" '$4 ~ var {print $4}') $LIB_DIR
fi

find . -not -path './lib/*' -type f -exec sh -c 'file -b {} | grep -q ELF' \; -print | sort -f | xargs -I{} libtree -pvv {} | tee libtree.txt
