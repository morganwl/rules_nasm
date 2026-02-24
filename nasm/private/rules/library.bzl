# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rules for assembling object files."""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cpp_toolchain")
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
    if workspace_root:
        raw_includes[workspace_root] = None
    raw_includes[gen_root] = None
    for inc in includes:
        if inc.startswith("/"):
            continue
        path = paths.join(relative_path, inc).lstrip("/")
        raw_includes[paths.join(workspace_root, path, "")] = None
        raw_includes[paths.join(gen_root, path, "")] = None

    # The prior rules auto-added source-relative -I paths...
    # Typically bazel rules assume includes use workspace-relative paths, so
    # this should be removed and includes = ["."] should be added to the rules
    # which depend on having import "foo.i" read from the current directory.
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

    env = {}

    # Add any environment variables available from a configured CC toolchain.
    cc_toolchain = find_cpp_toolchain(ctx)
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
    toolchains = [
        "//nasm:toolchain_type",
        config_common.toolchain_type("@rules_cc//cc:toolchain_type", mandatory = False),
    ],
    fragments = ["cpp"],
)
