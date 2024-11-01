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
RULES_NASM_VERSION = "${TAG:1}"
bazel_dep(name = "rules_nasm", version = RULES_NASM_VERSION)
archive_override(
    module_name = "rules_nasm",
    strip_prefix = "rules_nasm-%s"%RULES_NASM_VERSION,
    urls = [
        "https://github.com/morganwl/rules_nasm/archive/refs/tags/%s.tar.gz"%RULE_NASM_VERSION,
    ],
)

# configure the toolchain
nasm = use_extension("@rules_nasm//nasm:extensions.bzl", "nasm")
nasm.toolchain(
    nasm_version = "2.16.03",
)
\`\`\`

**NB**:
- The \`archive_override\` is required until \`rules_nasm\` is submitted to the Bazel Central Registry. This override must be performed in the main repository.
- The toolchain must be explicitly configured with a particular version of \`nasm\`.

EOF
