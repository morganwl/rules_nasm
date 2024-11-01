# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rule for nasm binary targets."""

load(":library.bzl", "nasm_library")

def nasm_binary(name, src, hdrs=None, preincs=None, includes=None, **kwargs):
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
      src: The assembly source file.
      hdrs: Other assembly sources which may be included by `src`.
            preincs: Assembly sources which will be included and processed
            before the source file. Sources will be included in the order
            listed.
      preincs: Assembly sources which will be included and processed before the source file.
               Sources will be included in the order listed.
      includes: Directories which will be added to the search path for include files.
      **kwargs: Additional keyword arguments passed to the `cc_binary` rule.
    """

    nasm_library(
        name = name + "_lib",
        src = src,
        hdrs = hdrs,
        preincs = preincs,
        includes = includes,
    )

    native.cc_binary(
        name = name,
        srcs = [":%s_lib"%name],
        **kwargs
    )
