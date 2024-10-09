# Copyright (c) 2024 Morgan Wajda-Levie.

"""Toolchain rules used by nasm."""

def _nasm_toolchain_impl(ctx):
    compiler = ctx.executable.target
    return [platform_common.ToolchainInfo(
        name = ctx.label.name,
        compiler = compiler,
        args = ctx.attr.args,
    )]

_nasm_toolchain = rule(
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

def nasm_toolchain(name, target, exec_compatible_with = None):
    _nasm_toolchain(
        name = name,
        target = target,
        args = select({
            Label("//nasm:elf64"): ["-felf64"],
            Label("//nasm:macho64"): ["-fmacho64"],
            "//conditions:default": [],
        })
    )

    native.toolchain(
        name = name + "_toolchain",
        toolchain = ":" + name,
        toolchain_type = Label("//nasm:toolchain_type"),
        exec_compatible_with = exec_compatible_with,
    )

def _nasm_assembler_impl(ctx):
    nasm_info = ctx.toolchains["//nasm:toolchain_type"]
    symlink = ctx.actions.declare_file("nasm")
    ctx.actions.symlink(
        output = symlink,
        target_file = nasm_info.compiler,
        is_executable = True,
    )
    print(symlink)
    return [
        DefaultInfo(files = depset([symlink]))
    ]

nasm_assembler = rule(
    implementation = _nasm_assembler_impl,
    toolchains = ["//nasm:toolchain_type"],
)
