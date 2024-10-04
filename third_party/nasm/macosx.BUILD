# Copyright (c) 2024 Morgan Wajda-Levie.

"""Nasm toolchain for MacOS."""

filegroup(
    name = "nasm_file",
    srcs = ["nasm"],
)

genrule(
    name = "compiler",
    srcs = [":nasm_file"],
    outs = ["bin/nasm"],
    executable = True,
    cmd = "cp $< $@",
    visibility = ["//visibility:public"],
)
