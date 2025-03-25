# Copyright (c) 2024 Morgan Wajda-Levie.

"""Toolchain rules used by nasm."""

TOOLCHAIN_TYPE = str(Label("//nasm:toolchain_type"))

def _nasm_toolchain_impl(ctx):
    nasm = ctx.executable.nasm
    all_files = depset([nasm], transitive = [
        ctx.attr.nasm[DefaultInfo].files,
        ctx.attr.nasm[DefaultInfo].default_runfiles.files,
    ])

    return [platform_common.ToolchainInfo(
        nasm = nasm,
        copts = ctx.attr.copts,
        all_files = all_files,

        # Legacy
        name = ctx.label.name,
        compiler = nasm,
        args = ctx.attr.copts,
    )]

nasm_toolchain = rule(
    doc = """\
A toolchain for configuring `nasm` rules.

A toolchain can be defined by adding a snippet like the following
somewhere in a `BUILD.bazel` file within your workspace.

```python
load("@rules_nasm//nasm:defs.bzl", "nasm_toolchain")

nasm_toolchain(
    name = "nasm_toolchain",
    copts = select({
        "//nasm:elf64": ["-felf64"],
        "//nasm:macho64": ["-fmacho64"],
        "//conditions:default": [],
    }),
    nasm = "@nasm",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "toolchain",
    toolchain = ":nasm_toolchain",
    toolchain_type = "@rules_nasm//nasm:toolchain_type",
    visibility = ["//visibility:public"],
)
```

Once the toolchain is defined, it will need to be registered in the `MODULE.bazel` file.

```python
register_toolchains("//:nasm_toolchain")
```
""",
    implementation = _nasm_toolchain_impl,
    attrs = {
        "copts": attr.string_list(
            doc = "Default arguments to pass to the `nasm` executable.",
        ),
        "nasm": attr.label(
            doc = "The `nasm` executable.",
            cfg = "exec",
            allow_files = True,
            executable = True,
        ),
    },
)

def _current_nasm_assembler_impl(ctx):
    nasm_info = ctx.toolchains[TOOLCHAIN_TYPE]
    is_windows = nasm_info.compiler.basename.endswith(".exe")
    symlink = ctx.actions.declare_file("nasm{}".format(".exe" if is_windows else ""))
    ctx.actions.symlink(
        output = symlink,
        target_file = nasm_info.compiler,
        is_executable = True,
    )
    return [
        DefaultInfo(
            files = depset([symlink]),
            executable = symlink,
        ),
    ]

current_nasm_assembler = rule(
    doc = "A rule for exposing the `nasm` assembler from the currently configured `nasm_toolchain`.",
    implementation = _current_nasm_assembler_impl,
    toolchains = [TOOLCHAIN_TYPE],
    executable = True,
)
