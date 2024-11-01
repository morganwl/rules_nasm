#!/bin/bash
#
# e2e/test.sh [bazel-options]
# Run all end-to-end tests

e2e_path=$(which "$0")
base_dir="${e2e_path%/*}"
owd="$(pwd)"
set -e
if [[ -n "$base_dir" ]]; then
    cd "$base_dir"
fi

for d in $(ls); do
    if [[ -d "$d" ]]; then
        cd "$d"
        rm remote.bazelrc 2> /dev/null || true
        ln -s "$(git rev-parse --show-toplevel)/.github/workflows/remote.bazelrc" remote.bazelrc
        echo "TEST: bazel test //... ${@}"
        bazel test //... "${@}"
        rm remote.bazelrc
        cd ..
    fi
done

cd "$owd"