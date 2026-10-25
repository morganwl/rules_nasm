"""Simple CC toolchain configuration rule."""

load("@rules_cc//cc:cc_toolchain_config_lib.bzl", "tool_path")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("@rules_cc//cc/toolchains:cc_toolchain_config_info.bzl", "CcToolchainConfigInfo")

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
                    "-%s-%s" % (ctx.attr.compiler, ctx.attr.compiler_version) if tool == "gcc" else "-%s" % tool
                ),
            )
            for tool in [
                "gcc",
                "cpp",
                "ld",
                "ar",
                "nm",
                "objdump",
                "strip",
            ]
        ],
        cxx_builtin_include_directories = [
            "/usr/x86_64-linux-gnu/include",
        ],
    )

cc_toolchain_config = rule(
    implementation = _cc_toolchain_config_impl,
    attrs = {
        "abi_libc_version": attr.string(
            doc = "The ABI version of the C library used by the target, e.g. `glibc_2.36`.",
        ),
        "abi_version": attr.string(
            doc = "The ABI version of the toolchain, e.g. `gcc`.",
        ),
        "compiler": attr.string(
            doc = "The name of the compiler, e.g. `gcc`. Combined with `compiler_version` to locate the compiler binary.",
        ),
        "compiler_version": attr.string(
            mandatory = True,
            doc = "Major version of the compiler.",
        ),
        "host_system_name": attr.string(
            doc = "The system name of the host (execution) platform.",
            default = "local",
        ),
        "target_system_name": attr.string(
            doc = "The GNU system name of the target platform, e.g. `x86_64-linux-gnu`.",
            default = "local",
        ),
        "toolchain_identifier": attr.string(
            doc = "A unique identifier for this toolchain configuration, used in Bazel's output and error messages.",
        ),
        "toolchain_prefix": attr.string(
            doc = "Prefix path to toolchain binaries, eg [prefix]-ld.",
            mandatory = True,
        ),
    },
    provides = [CcToolchainConfigInfo],
)
