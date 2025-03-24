#!/bin/bash
#
# e2e/test.sh [bazel-options]
# Run all end-to-end tests

e2e_path=$(which "$0")
base_dir="${e2e_path%/*}"
owd="$(pwd)"
set -e
if [[ $1 == --bazelrc=* ]]; then
    bazelrc="$1"
    shift
fi
if [[ -n "$base_dir" ]]; then
    cd "$base_dir"
fi

for d in $(ls); do
    if [[ -d "$d" ]]; then
        echo "$d"
        cd "$d"
        echo "TEST: bazel test //... ${@}"
        bazel $bazelrc test //... "${@}"
        cd ..
    fi
done

cd "$owd"
