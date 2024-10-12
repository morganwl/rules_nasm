# Copyright (c) 2024 Morgan Wajda-Levie.

"""Nasm toolchain for MacOS."""

filegroup(
    name = "nasm_file",
    srcs = ["nasm"],
)

genrule(
    name = "assembler",
    srcs = [":nasm_file"],
    outs = ["bin/nasm"],
    executable = True,
    cmd = "cp $< $@",
    visibility = ["//visibility:public"],
)

nasm_toolchain(
    name = "toolchain_impl",
    target = "//:assembler",
    visibility = ["//visibility:public"],
    args = select({
            "@rules_nasm//nasm:elf64": ["-felf64"],
            "@rules_nasm//nasm:macho64": ["-fmacho64"],
            "//conditions:default": [],
        }),
)
