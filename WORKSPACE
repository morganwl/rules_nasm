workspace(
    name = "rules_nasm",
)

load("//nasm:deps.bzl", "rules_nasm_dependencies")
rules_nasm_dependencies()
load("@bazel_features//:deps.bzl", "bazel_features_deps")
bazel_features_deps()
load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")
rules_foreign_cc_dependencies()
bazel_features_deps()
load("//nasm:toolchains.bzl", "nasm_register_toolchains")
nasm_register_toolchains()
