# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rules for assembling object files."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain", "use_cc_toolchain")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")

def get_environment_variables(ctx, cc_toolchain):
    """Get environment variables for running autoconf checks.

    Args:
        ctx (ctx): The rule context.
        cc_toolchain (cc_toolchain): The cc_toolchain to query.

    Returns:
        A dictionary of environment variables.
    """
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    compile_variables_for_env = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        user_compile_flags = ctx.fragments.cpp.copts + ctx.fragments.cpp.cxxopts,
    )
    compile_env = cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.c_compile,
        variables = compile_variables_for_env,
    )
    link_variables_for_env = cc_common.create_link_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        is_linking_dynamic_library = False,
        is_static_linking_mode = True,
    )
    link_env = cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = ACTION_NAMES.cpp_link_executable,
        variables = link_variables_for_env,
    )

    # Merge compile and link environment variables, with compile taking precedence
    # since it has the critical INCLUDE paths for MSVC
    return link_env | compile_env

def _include_dir(include):
    """Render an include directory for a `NasmAssemble` command line.

    This is an `Args.add_all` `map_each` callback. Directories within the output
    tree are derived from the path of a `File` in that tree instead of from
    `ctx.bin_dir.path` so they remain correct under path mapping
    (`--experimental_output_paths=strip`), where `File.path` is rewritten at the
    time the command line is expanded.

    Args:
        include (struct): A struct with the fields `anchor` (`File` or `None`),
            `strip` (`int`) and `path` (`str`). When `anchor` is `None`, `path`
            is used as is. Otherwise `strip` characters are removed from the end
            of `anchor.path` and `path` is appended to the result.

    Returns:
        str: The include directory.
    """
    if include.anchor == None:
        path = include.path
    else:
        anchor = include.anchor.path
        path = anchor[:len(anchor) - include.strip] + include.path
    return path or "./"

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
    suffix = ".o"
    if nasm_toolchain.compiler.basename.endswith(".exe"):
        suffix = ".obj"

    # A single .asm file could be compiled by multiple targets, so construct
    # the output name as _obj/path/to/target/basename.obj
    out_name = paths.join("_obj", ctx.label.name, src.basename + suffix)
    out = ctx.actions.declare_file(out_name)

    # `out.path` is `<out.root.path>/<repo relative path>`. Include directories
    # in the output tree are produced by stripping the repo relative path from
    # `out.path` within the `_include_dir` callback, which sees the path-mapped
    # `out.path`.
    bin_strip = len(out.path) - len(out.root.path) - 1

    workspace_root = src.owner.workspace_root
    if workspace_root:
        workspace_root = workspace_root + "/"

    relative_path = ""
    if src.owner.package:
        relative_path = src.owner.package + "/"

    # Generate the set of -I paths. Each is looked up in both the source tree
    # and the output tree. The dict drops duplicates while preserving order.
    include_dirs = {}
    if workspace_root:
        include_dirs["src:" + workspace_root] = struct(anchor = None, strip = 0, path = workspace_root)
    include_dirs["out:" + workspace_root] = struct(anchor = out, strip = bin_strip, path = workspace_root)
    for inc in includes:
        if inc.startswith("/"):
            continue
        path = paths.join(workspace_root, paths.join(relative_path, inc).lstrip("/"), "")
        include_dirs["src:" + path] = struct(anchor = None, strip = 0, path = path)
        include_dirs["out:" + path] = struct(anchor = out, strip = bin_strip, path = path)

    # The prior rules auto-added source-relative -I paths...
    # Typically bazel rules assume includes use workspace-relative paths, so
    # this should be removed and includes = ["."] should be added to the rules
    # which depend on having import "foo.i" read from the current directory.
    if src.is_source:
        src_dir = src.path[:-len(src.basename)]
        include_dirs["src:" + src_dir] = struct(anchor = None, strip = 0, path = src_dir)
    else:
        include_dirs["dir:" + src.path] = struct(anchor = src, strip = len(src.basename), path = "")

    # Generate the actual args.
    args = ctx.actions.args()
    args.add_all(nasm_toolchain.copts)
    args.add_all(include_dirs.values(), map_each = _include_dir, before_each = "-I")
    args.add_all(preincs, before_each = "-p")
    args.add_all(copts)
    args.add("-o", out)
    args.add(src)

    inputs = depset([src] + preincs, transitive = [hdrs])

    env = {}

    # Add any environment variables available from a configured CC toolchain.
    cc_toolchain = find_cc_toolchain(ctx, mandatory = False)
    if cc_toolchain:
        env.update(get_environment_variables(ctx, cc_toolchain))

    ctx.actions.run(
        mnemonic = "NasmAssemble",
        executable = nasm_toolchain.nasm,
        arguments = [args],
        inputs = inputs,
        outputs = [out],
        tools = nasm_toolchain.all_files,
        env = env | ctx.configuration.default_shell_env,
        # All paths generated by this rule are derived from `File` objects when
        # the command line is expanded, so this action supports path mapping.
        # User provided `copts` and the toolchain environment are passed through
        # verbatim and must not contain configuration specific output paths.
        execution_requirements = {"supports-path-mapping": "1"},
        toolchain = Label("//nasm:toolchain_type"),
    )

    return out

_NASM_EXTENSIONS = [".asm", ".nasm", ".s"]
_NASM_INCLUDES = _NASM_EXTENSIONS + [".i", ".inc"]

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
    toolchains = ["//nasm:toolchain_type"] + use_cc_toolchain(mandatory = False),
    fragments = ["cpp"],
)
