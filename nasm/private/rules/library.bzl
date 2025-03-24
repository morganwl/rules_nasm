# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rules for assembling object files."""

load("@rules_cc//cc:cc_library.bzl", "cc_library")

NASM_EXTENSIONS = [".asm", ".nasm", ".s", ".i"]

def _nasm_library_impl(ctx):
    """Implement nasm library object."""
    src = ctx.file.src
    preincs = ctx.files.preincs
    workspace_root = ctx.file.src.owner.workspace_root
    if workspace_root:
        workspace_root = workspace_root + "/"
    package_path = workspace_root + ctx.file.src.owner.package
    inputs = depset([src] + preincs, transitive = [depset(ctx.files.hdrs)])
    out = ctx.actions.declare_file(ctx.label.name + ".o")

    nasm_info = ctx.toolchains["//nasm:toolchain_type"]

    args = ctx.actions.args()
    args.add_all(nasm_info.args)
    args.add("-I", src.dirname + "/")
    if workspace_root:
        args.add("-I", workspace_root)
    args.add_all(
        [
            "%s/%s" % (package_path, inc)
            for inc in ctx.attr.includes
        ],
        before_each = "-I",
    )
    args.add("-o", out)
    args.add_all(preincs, before_each = "-p")
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
        "hdrs": attr.label_list(
            allow_files = NASM_EXTENSIONS,
            doc = (
                "Other assembly sources which may be included by `src`. " +
                "Must have an extension of %s." % (
                    ", ".join(NASM_EXTENSIONS)
                )
            ),
        ),
        "includes": attr.string_list(
            doc = ("Directories which will be added to the search path for include files."),
        ),
        "preincs": attr.label_list(
            allow_files = NASM_EXTENSIONS,
            doc = (
                "Assembly sources which will be included and processed before the source file. " +
                "Sources will be included in the order listed. Must have an extension of %s." % (
                    ", ".join(NASM_EXTENSIONS)
                )
            ),
        ),
        "src": attr.label(
            allow_single_file = NASM_EXTENSIONS,
            doc = "The assembly source file. Must have an extension of %s." % (
                ", ".join(NASM_EXTENSIONS)
            ),
        ),
    },
    toolchains = ["//nasm:toolchain_type"],
)

def nasm_library(name, src, hdrs = None, preincs = None, includes = None, **kwargs):
    """Assemble an `nasm` source for use as a C++ dependency.

    Assembled object files should be usable as C compilation units.
    Rather than create a `CcInfo` object directly, we pass the assembled
    object file as the src to a `cc_library` rule, which creates a
    corresponding provider, and captures any additional dependencies.

    Args:
      name: A unique name for this target.
      src: The assembly source file.
      hdrs: Other assembly sources which may be included by `src`.
      preincs: Assembly sources which will be included and processed before the source file.
               Sources will be included in the order listed.
      includes: Directories which will be added to the search path for include files.
      **kwargs: Additional keyword arguments passed to the `cc_library` rule.
    """
    _nasm_library_inner(
        name = "%s_asm" % name,
        src = src,
        hdrs = hdrs,
        preincs = preincs,
        includes = includes,
    )
    cc_library(
        name = name,
        srcs = [":%s_asm" % name],
        **kwargs
    )
