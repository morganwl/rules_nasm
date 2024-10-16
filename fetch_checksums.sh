#!/bin/bash

source_url() {
    echo "https://www.nasm.us/pub/nasm/releasebuilds/$1/nasm-$1.tar.gz"
}
mac_url() {
    echo "https://www.nasm.us/pub/nasm/releasebuilds/$1/macosx/nasm-$1-macosx.zip"
}
print_checksum() {
    url=$1
    if checksum=$(curl -sLf "$url" | sha256sum | awk '{print $1;}'); then
        format_checksum $url $checksum
    fi
}
format_checksum() {
    url=$1
    checksum=$2
    echo "   \"$url\":"
    echo "   \"$checksum\","
}

set -e
set -o pipefail

declare -a versions
PRINT_MAC="True"
PRINT_SOURCE="True"
if [ -n "$1" ]; then
    if [ $1 == "mac" ]; then
        PRINT_SOURCE=""
    fi
    if [ $1 == "source" ]; then
        PRINT_MAC=""
    fi
fi
versions=( $(curl -L https://www.nasm.us/pub/nasm/releasebuilds/ --stderr - | grep -P '(?<=href=")\d+\.\d+\.\d+(rc\d+)?' -o) )

echo "NASM_URLS = {"

for v in "${versions[@]}"; do
    if [ -n "$PRINT_SOURCE" ]; then
        url=$(source_url $v)
        print_checksum $url
    fi
    if [ -n "$PRINT_MAC" ]; then
        url=$(mac_url $v)
        print_checksum $url
    fi
done

echo "}"
