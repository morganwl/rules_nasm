"""Dependencies for WORKSPACE file."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def rules_nasm_dependencies():
    """Load any missing external repos required by rules_nasm."""

    # rules_foreign_cc is used if nasm needs to be built from source
    maybe(
        http_archive,
        name = "rules_foreign_cc",
        sha256 = "a2e6fb56e649c1ee79703e99aa0c9d13c6cc53c8d7a0cbb8797ab2888bbc99a3",
        strip_prefix = "rules_foreign_cc-0.12.0",
        url = "https://github.com/bazelbuild/rules_foreign_cc/releases/download/0.12.0/rules_foreign_cc-0.12.0.tar.gz",
    )

    # bazel_features is used by rules_foreign_cc
    maybe(
        http_archive,
        name = "bazel_features",
        sha256 = "b4b145c19e08fd48337f53c383db46398d0a810002907ff0c590762d926e05be",
        strip_prefix = "bazel_features-1.18.0",
        url = "https://github.com/bazel-contrib/bazel_features/releases/download/v1.18.0/bazel_features-v1.18.0.tar.gz",
    )
