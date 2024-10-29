# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rule for nasm test targets."""

load(":library.bzl", "nasm_library")

def nasm_test(name, src, size=None, includes=None, **kwargs):
    """Assemble and execute a test assembly program."""

    nasm_library(
        name = name + "_lib",
        src = src,
        includes = includes,
    )

    native.cc_test(
        name = name,
        size = size,
        srcs = [":%s_lib"%name],
        **kwargs
    )
