# Copyright (c) 2024 Morgan Wajda-Levie.

"""Nasm toolchain for MacOS."""

filegroup(
    name = "nasm_file",
    srcs = ["nasm"],
)

genrule(
    name = "nasm",
    srcs = [":nasm_file"],
    outs = ["nasm"],
    executable = True,
    cmd = "cp $< $@",
)
