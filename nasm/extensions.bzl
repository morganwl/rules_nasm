# Copyright (c) 2024 Morgan Wajda-Levie.

"""Nasm extension for use with bzlmod."""

# http_file = use_repo_rule("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("//nasm:toolchains.bzl", "nasm_declare_toolchain_repos", "nasm_toolchains")

OS_MAP = {
    'mac os x': 'macos',
}

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
        ),
        "_repo_name": attr.string(
            doc = ("Name of repo where toolchains will be registered. For internal use."),
            default = "nasm_toolchains",
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
    configuration_groups = {"nasm_toolchains": {}}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            group = toolchain._repo_name
            if group not in configuration_groups:
                configuration_groups[group] = {}
            configuration_groups[group][(toolchain.nasm_version, toolchain.require_source)] = True
    return configuration_groups

def map_os(java_os):
    return OS_MAP.get(java_os, java_os)

def _nasm_impl(module_ctx):
    host_os = map_os(module_ctx.os.name)
    print(host_os)
    config_groups = get_unique_toolchain_tags(module_ctx)
    for name, group in config_groups.items():
        toolchains = nasm_declare_toolchain_repos(group, host_os)
        nasm_toolchains(
            name = name,
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
