# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rules for assembling object files."""

def nasm_assemble(
        *,
        ctx,
        nasm_toolchain,
        src,
        copts,
        hdrs,
        preincs,
        includes):
    """Spawn a `NasmAssemble` action to convert an assembly source file to an object file.

    Args:
        ctx (ctx): The rule's context object
        nasm_toolchain (nasm_toolchain): The current nasm toolchain
        src (File): The source file to compile
        copts (list[str]): Additional compile flags to use.
        hdrs (depset[file]): Headers to include.
        preincs (list[file]): Pre include files.
        includes (list[str]): Include flags.

    Returns:
        File: The compiled object file.
    """
    basename, _, _ = src.basename.rpartition(".")
    out = ctx.actions.declare_file("{}/_obj/{}/{}.o".format(
        ctx.label.package,
        ctx.label.name,
        basename,
    ))

    workspace_root = src.owner.workspace_root
    if workspace_root:
        workspace_root = workspace_root + "/"
    package_path = workspace_root + src.owner.package

    args = ctx.actions.args()
    args.add_all(nasm_toolchain.copts)
    args.add("-I", src.dirname + "/")

    if workspace_root:
        args.add("-I", workspace_root)

    args.add_all(
        [
            "%s/%s" % (package_path, inc)
            for inc in includes
        ],
        before_each = "-I",
    )
    args.add("-o", out)
    args.add_all(preincs, before_each = "-p")
    args.add_all(copts)
    args.add(src)

    inputs = depset([src] + preincs, transitive = [hdrs])

    ctx.actions.run(
        mnemonic = "NasmAssemble",
        executable = nasm_toolchain.nasm,
        arguments = [args],
        inputs = inputs,
        outputs = [out],
        tools = nasm_toolchain.all_files,
    )

    return out

_NASM_EXTENSIONS = [".asm", ".nasm", ".s", ".i"]

NASM_ATTRS = {
    "copts": attr.string_list(
        doc = "Additional compilation flags to `nasm`.",
    ),
    "hdrs": attr.label_list(
        allow_files = _NASM_EXTENSIONS,
        doc = (
            "Other assembly sources which may be included by `src`. " +
            "Must have an extension of %s." % (
                ", ".join(_NASM_EXTENSIONS)
            )
        ),
    ),
    "includes": attr.string_list(
        doc = ("Directories which will be added to the search path for include files."),
    ),
    "preincs": attr.label_list(
        allow_files = _NASM_EXTENSIONS,
        doc = (
            "Assembly sources which will be included and processed before the source file. " +
            "Sources will be included in the order listed. Must have an extension of %s." % (
                ", ".join(_NASM_EXTENSIONS)
            )
        ),
    ),
    "srcs": attr.label_list(
        allow_files = _NASM_EXTENSIONS,
        doc = "The assembly source file. Must have an extension of %s." % (
            ", ".join(_NASM_EXTENSIONS)
        ),
    ),
}

def _nasm_library_impl(ctx):
    """Implement nasm library object."""

    nasm_toolchain = ctx.toolchains["//nasm:toolchain_type"]

    hdrs = depset(ctx.files.hdrs)

    object_files = [
        nasm_assemble(
            ctx = ctx,
            nasm_toolchain = nasm_toolchain,
            src = src,
            hdrs = hdrs,
            copts = ctx.attr.copts,
            preincs = ctx.files.preincs,
            includes = ctx.attr.includes,
        )
        for src in ctx.files.srcs
    ]

    return [DefaultInfo(
        files = depset(object_files),
    )]

nasm_library = rule(
    implementation = _nasm_library_impl,
    doc = "Assemble an `nasm` source for use as a C++ dependency.",
    attrs = NASM_ATTRS,
    toolchains = ["//nasm:toolchain_type"],
)
