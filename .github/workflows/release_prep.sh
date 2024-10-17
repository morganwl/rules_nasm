#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same)
PREFIX="rules_nasm-${TAG:1}"
ARCHIVE="rules_nasm-$TAG.tar.gz"

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat << EOF
Minimum bazel version: **7.0.0**

**(Support for projects not using \`bzlmod\` will be added in a future
release.)**

If you're using \`bzlmod\`, add the following to \`MODULE.bazel\`:

\`\`\`starlark
bazel_dep(name = "rules_nasm", version = "${TAG:1}")

# configure the toolchain
nasm = use_extension("@rules_nasm//nasm:extensions.bzl", "nasm")
nasm.toolchain(
    nasm_version = "2.16.03",
)
\`\`\`

EOF
