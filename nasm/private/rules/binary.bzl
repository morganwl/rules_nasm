# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rule for nasm binary targets."""

load(":library.bzl", "nasm_library")

def nasm_binary(name, src, includes=None, **kwargs):
    nasm_library(
        name = name + "_lib",
        src = src,
        includes = includes,
    )

    native.cc_binary(
        name = name,
        srcs = [":%s_lib"%name],
        **kwargs
    )

