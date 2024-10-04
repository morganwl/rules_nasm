# Copyright (c) 2024 Morgan Wajda-Levie.

"""Public rules definitions for nasm."""

load("//nasm/private/rules:library.bzl", _nasm_library = "nasm_library")
load("//nasm/private/rules:test.bzl", _nasm_test = "nasm_test")
load("//nasm/private/rules:binary.bzl", _nasm_binary = "nasm_binary")

nasm_test = _nasm_test
nasm_library = _nasm_library
nasm_binary = _nasm_binary

def executable_foreign(name, src, output_group):
    """Expose a file a rules_foreign_cc target as an executable."""
    native.filegroup(
        name = name + "_grp",
        srcs = [src],
        output_group = output_group,
    )
    native.genrule(
        name = name,
        srcs = [":{}_grp".format(name)],
        outs = [output_group],
        executable = True,
        cmd = "cp $< $@",
    )


