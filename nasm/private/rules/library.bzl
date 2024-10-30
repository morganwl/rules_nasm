# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rules for assembling object files."""

NASM_EXTENSIONS = [".asm", ".nasm", ".s", ".i"]

def _nasm_library_impl(ctx):
    """Implement nasm library object."""
    src = ctx.file.src
    preincs = ctx.files.preincs
    inputs = depset([src] + preincs, transitive=[depset(ctx.files.hdrs)])
    out = ctx.actions.declare_file(ctx.label.name + '.o')

    nasm_info = ctx.toolchains["//nasm:toolchain_type"]

    args = ctx.actions.args()
    args.add_all(nasm_info.args)
    args.add("-I", src.dirname + "/")
    args.add("-o", out)
    args.add_all(preincs, before_each="-p")
    args.add(src)
    ctx.actions.run(
        mnemonic = "NasmAssemble",
        executable = nasm_info.compiler,
        arguments = [args],
        inputs = inputs,
        outputs = [out],
    )
    return [
        DefaultInfo(files = depset([out])),
    ]

_nasm_library_inner = rule(
    implementation = _nasm_library_impl,
    attrs = {
        "src": attr.label(allow_single_file = NASM_EXTENSIONS),
        "hdrs": attr.label_list(allow_files = NASM_EXTENSIONS),
        "preincs": attr.label_list(allow_files = NASM_EXTENSIONS),
    },
    toolchains = ["//nasm:toolchain_type"],
)

def nasm_library(name, src, hdrs=None, preincs=None, **kwargs):
    """Wrap nasm_library with a CC provider.

    Assembled object files should be usable as C compilation units.
    Rather than create a CcInfo object directly, we pass the assembled
    object file as the src to a cc_library rule, which creates a
    corresponding provider, and captures any additional dependencies.
    """
    _nasm_library_inner(
        name = "%s_asm"%name,
        src = src,
        hdrs = hdrs,
        preincs = preincs,
    )

    native.cc_library(
        name = name,
        srcs = [":%s_asm"%name],
        **kwargs,
    )
