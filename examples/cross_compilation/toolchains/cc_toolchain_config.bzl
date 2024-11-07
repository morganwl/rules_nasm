"""Simple CC toolchain configuration rule."""

load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "tool_path")

def _cc_toolchain_config_impl(ctx):
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = ctx.attr.toolchain_identifier,
        host_system_name = ctx.attr.host_system_name,
        target_system_name = ctx.attr.target_system_name,
        target_cpu = "k8",
        target_libc = "unknown",
        compiler = ctx.attr.compiler,
        abi_version = ctx.attr.abi_version,
        abi_libc_version = ctx.attr.abi_libc_version,
        tool_paths = [
            tool_path(
                name = tool,
                path = ctx.attr.toolchain_prefix + (
                    "-%s-%s"%(ctx.attr.compiler, ctx.attr.compiler_version)
                    if tool == "gcc" else "-%s"%tool
                ),
            )
            for tool in [
                "gcc", "cpp", "ld", "ar", "nm", "objdump", "strip"
            ]
        ],
        cxx_builtin_include_directories = [
            "/usr/x86_64-linux-gnu/include",
        ]
    )

cc_toolchain_config = rule(
    implementation = _cc_toolchain_config_impl,
    attrs = {
        "toolchain_identifier": attr.string(),
        "host_system_name": attr.string(default = "local"),
        "target_system_name": attr.string(default = "local"),
        "compiler": attr.string(),
        "abi_version": attr.string(),
        "abi_libc_version": attr.string(),
        "toolchain_prefix": attr.string(
            mandatory=True,
            doc = "Prefix path to toolchain binaries, eg [prefix]-ld."
        ),
        "compiler_version": attr.string(
            mandatory=True,
            doc = "Major version of the compiler."
        ),
    },
    provides = [CcToolchainConfigInfo],
)
