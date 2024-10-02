# Copyright (c) 2024 Morgan Wajda-Levie.

"""Toolchain rules used by nasm."""

def _nasm_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        name = ctx.label.name,
        compiler_path = ctx.attr.compiler_path,
        args = ctx.attr.args,
    )]

nasm_toolchain = rule(
    implementation = _nasm_toolchain_impl,
    attrs = {
        "compiler_path": attr.string(),
        "args": attr.string_list(),
    },
)
