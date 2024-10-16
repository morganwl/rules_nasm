workspace(
    name = "rules_nasm",
)

load("//nasm:deps.bzl", "rules_nasm_dependencies")
rules_nasm_dependencies()

load("@bazel_features//:deps.bzl", "bazel_features_deps")
bazel_features_deps()

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies",
    "nasm_register_toolchains")
rules_foreign_cc_dependencies()

nasm_register_toolchains("2.16.03")
