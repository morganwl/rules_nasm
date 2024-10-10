# Copyright (c) 2024 Morgan Wajda-Levie.

"""Nasm extension for use with bzlmod."""

# http_file = use_repo_rule("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//nasm:toolchains.bzl", "nasm_fetch_toolchains")

_toolchain = tag_class(
    attrs = {
        "nasm_version": attr.string(
            doc = "One of the supported versions of nasm.",
            mandatory = True,
        ),
        "require_source": attr.bool(
            doc = ("Build nasm from source, even when a compatible binary " +
                   "release is available."),
            default = False,
        )
    }
)

def _nasm_impl(mctx):
    for mod in mctx.modules:
        if mod.is_root and len(mod.tags.toolchain) > 0:
            nasm_fetch_toolchains()

nasm = module_extension(
    implementation = _nasm_impl,
    tag_classes = {
        "toolchain": _toolchain,
    },
)
