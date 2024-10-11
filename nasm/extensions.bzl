# Copyright (c) 2024 Morgan Wajda-Levie.

"""Nasm extension for use with bzlmod."""

# http_file = use_repo_rule("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//nasm:toolchains.bzl", "nasm_declare_toolchain_repos", "nasm_toolchains")

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

def get_unique_toolchain_tags(module_ctx):
    """Get all unique toolchain tags.

    Args:
        module_ctx: The context of rules_nasm.

    Returns:
        A dictionary of (version, require_source) tuples.
    """
    configurations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            configurations[(toolchain.nasm_version, toolchain.require_source)] = True
    return configurations

def _nasm_impl(module_ctx):
    host_os = module_ctx.os.name
    configurations = get_unique_toolchain_tags(module_ctx)
    toolchains = nasm_declare_toolchain_repos(configurations, host_os)
    nasm_toolchains(
        name = "nasm_toolchains",
        toolchains = toolchains,
    )
    # identify all unique requested toolchains
    # fetch a repo for each requested toolchain
    # create a single repo referencing all requested toolchains

nasm = module_extension(
    implementation = _nasm_impl,
    tag_classes = {
        "toolchain": _toolchain,
    },
)
