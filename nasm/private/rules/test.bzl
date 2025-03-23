# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rule for nasm test targets."""

load("@rules_cc//cc:cc_test.bzl", "cc_test")
load(":library.bzl", "nasm_library")

def nasm_test(name, src, size = None, hdrs = None, preincs = None, includes = None, **kwargs):
    """Assemble and execute a test assembly program.

    Args:
      name: A unique name for this target.
      src: The assembly source file.
      size: The "heaviness" of a test target. See [Bazel reference](https://bazel.build/reference/be/common-definitions#test.size) for details.
      hdrs: Other assembly sources which may be included by `src`.
            preincs: Assembly sources which will be included and processed
            before the source file. Sources will be included in the order
            listed.
      preincs: Assembly sources which will be included and processed before the source file.
               Sources will be included in the order listed.
      includes: Directories which will be added to the search path for include files.
      **kwargs: Additional keyword arguments passed to the `cc_test` rule.
    """

    nasm_library(
        name = name + "_lib",
        src = src,
        hdrs = hdrs,
        preincs = preincs,
        includes = includes,
    )
    cc_test(
        name = name,
        size = size,
        srcs = [":%s_lib" % name],
        **kwargs
    )
