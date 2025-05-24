# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rules for assembling object files."""

def _construct_include(inc, relative_path):
    """Constructs the workspace-relative portion of an include path."""
    if inc.startswith("/")
        # cc_* rules assume that when an include starts with a leading / then it is workspace
        # relative, otherwise it is package relative.  Mimic that here.
        inc = inc.lstrip("/").rstrip("/")
        if inc == "." or inc == "":
            return ""
        else:
            return inc + "/"
    inc.rstrip("/")
    if inc == ".":
        return relative_path:
    else:
        return relative_path + inc + "/"


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
    out_root = "_obj"
    if ctx.label.package:
        out_root = "{}/_obj".format(ctx.label.package)

    out = ctx.actions.declare_file("{}/{}/{}.o".format(
        out_root,
        ctx.label.name,
        basename,
    ))

    workspace_root = src.owner.workspace_root
    if workspace_root:
        workspace_root = workspace_root + "/"
    gen_root = ctx.genfiles_dir.path + "/" + workspace_root

    relative_path = ""
    if src.owner.package:
        relative_path = src.owner.package + "/"

    # Generate the set of -I paths.
    # set() doesn't exist until recent starlark/bazel
    raw_includes = {}
    raw_includes[workspace_root] = None
    raw_includes[gen_root] = None
    for inc in includes:
        # Add both the source and generated paths for each include
        path = _construct_include(inc, relative_path)
        raw_includes[workspace_root + path] = None
        raw_includes[gen_root + path] = None

    # The prior rules auto-added source-relative -I paths...
    # Typically bazel rules require includes to use relative paths
    # from the workspace root, so this should be removed.
    raw_includes[src.dirname + "/"] = None

    # Generate the actual args.
    args = ctx.actions.args()
    args.add_all(nasm_toolchain.copts)
    args.add_all(raw_includes.keys(), before_each = "-I")
    args.add_all(preincs, before_each = "-p")
    args.add_all(copts)
    args.add("-o", out)
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
_NASM_INCLUDES = _NASM_EXTENSIONS + [".inc", ".inc.h"]

NASM_ATTRS = {
    "copts": attr.string_list(
        doc = "Additional compilation flags to `nasm`.",
    ),
    "hdrs": attr.label_list(
        allow_files = _NASM_INCLUDES,
        doc = (
            "Other assembly sources which may be included by `src`. " +
            "Must have an extension of %s." % (
                ", ".join(_NASM_INCLUDES)
            )
        ),
    ),
    "includes": attr.string_list(
        doc = ("Directories which will be added to the search path for include files."),
    ),
    "preincs": attr.label_list(
        allow_files = _NASM_INCLUDES,
        doc = (
            "Assembly sources which will be included and processed before the source file. " +
            "Sources will be included in the order listed. Must have an extension of %s." % (
                ", ".join(_NASM_INCLUDES)
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
