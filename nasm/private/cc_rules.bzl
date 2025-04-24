# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rule for nasm cc targets."""

load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_cc//cc:cc_test.bzl", "cc_test")
load("//nasm/private/rules:library.bzl", _nasm_library = "nasm_library")

def nasm_cc_rule(
        *,
        cc_rule,
        name,
        srcs,
        hdrs = None,
        preincs = None,
        includes = None,
        **kwargs):
    """Assemble an `nasm` source for use as a C++ dependency.

    Args:
        cc_rule: The rule to pass `nasm_library` results to.
        name: A unique name for this target.
        srcs: The assembly source files.
        hdrs: Other assembly sources which may be included by `srcs`.
        preincs: Assembly sources which will be included and processed before the source file.
               Sources will be included in the order listed.
        includes: Directories which will be added to the search path for include files.
        **kwargs: Additional keyword arguments passed to the `cc_library` rule.
    """
    tags = kwargs.pop("tags", [])

    nasm_args = {}
    for arg in [
        "compatible_with",
        "exec_compatible_with",
        "target_compatible_with",
        "toolchains",
    ]:
        if arg in kwargs:
            nasm_args[arg] = kwargs[arg]

    _nasm_library(
        name = name + "_asm",
        srcs = srcs,
        hdrs = hdrs,
        preincs = preincs,
        includes = includes,
        tags = depset(tags + ["manual"]).to_list(),
        visibility = ["//visibility:private"],
        **nasm_args
    )

    cc_rule(
        name = name,
        srcs = [name + "_asm"],
        tags = tags,
        **kwargs
    )

def nasm_cc_library(
        *,
        name,
        srcs,
        hdrs = None,
        preincs = None,
        includes = None,
        **kwargs):
    """Assemble an `nasm` source for use as a C++ dependency.

    Assembled object files should be usable as C compilation units.
    Rather than create a `CcInfo` object directly, we pass the assembled
    object file as the src to a `cc_library` rule, which creates a
    corresponding provider, and captures any additional dependencies.

    Args:
        name: A unique name for this target.
        srcs: The assembly source files.
        hdrs: Other assembly sources which may be included by `srcs`.
        preincs: Assembly sources which will be included and processed before the source file.
               Sources will be included in the order listed.
        includes: Directories which will be added to the search path for include files.
        **kwargs: Additional keyword arguments passed to the `cc_library` rule.
    """
    nasm_cc_rule(
        cc_rule = cc_library,
        name = name,
        srcs = srcs,
        hdrs = hdrs,
        preincs = preincs,
        includes = includes,
        **kwargs
    )

def nasm_cc_binary(
        *,
        name,
        srcs,
        hdrs = None,
        preincs = None,
        includes = None,
        **kwargs):
    """Assemble a source file as an executable.

    Assembles an `nasm` source file as an executable binary. The
    assembled object file will be linked against the C standard library,
    meaning that it must define a starting function with the label
    expected by system libraries, can reference C standard library
    functions, and must not export labels which conflict with the C
    standard library.

    *(Standalone binaries which are not linked to standard libraries are
    planned for a future release.)*

    **NB**: The mangling of function labels is defined by the ABI of the
    target platform. Some degree of portability can be ensured by using
    a macro to define global labels, and deduce the target platform by
    inspecting the target binary format.

    Args:
        name: A unique name for this target.
        srcs: The assembly source files.
        hdrs: Other assembly sources which may be included by `srcs`.
        preincs: Assembly sources which will be included and processed
            before the source file. Sources will be included in the order
            listed.
        includes: Directories which will be added to the search path for include files.
        **kwargs: Additional keyword arguments passed to the `cc_binary` rule.
    """
    nasm_cc_rule(
        cc_rule = cc_binary,
        name = name,
        srcs = srcs,
        hdrs = hdrs,
        preincs = preincs,
        includes = includes,
        **kwargs
    )

def nasm_cc_test(
        *,
        name,
        srcs,
        size = None,
        hdrs = None,
        preincs = None,
        includes = None,
        **kwargs):
    """Assemble and execute a test assembly program.

    Args:
        name: A unique name for this target.
        srcs: The assembly source files.
        size: The "heaviness" of a test target. See [Bazel reference](https://bazel.build/reference/be/common-definitions#test.size) for details.
        hdrs: Other assembly sources which may be included by `srcs`.
        preincs: Assembly sources which will be included and processed
            before the source file. Sources will be included in the order
            listed.
        includes: Directories which will be added to the search path for include files.
        **kwargs: Additional keyword arguments passed to the `cc_test` rule.
    """

    nasm_cc_rule(
        cc_rule = cc_test,
        name = name,
        srcs = srcs,
        hdrs = hdrs,
        preincs = preincs,
        includes = includes,
        size = size,
        **kwargs
    )
