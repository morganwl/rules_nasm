# Copyright (c) 2024 Morgan Wajda-Levie.

"""Toolchain rules used by nasm."""

def _nasm_toolchain_impl(ctx):
    compiler = ctx.executable.target
    return [platform_common.ToolchainInfo(
        name = ctx.label.name,
        compiler = compiler,
        # compiler_path = compiler_path,
        args = ctx.attr.args,
    )]

nasm_toolchain = rule(
    implementation = _nasm_toolchain_impl,
    attrs = {
        "target": attr.label(
            cfg = "exec",
            allow_files = True,
            executable = True,
        ),
        "args": attr.string_list(),
    },
)
