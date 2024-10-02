# Copyright (c) 2024 Morgan Wajda-Levie.

"""Rule for nasm test targets."""

def _nasm_test_impl(ctx):
    """Implement nasm test."""


def nasm_test(name, srcs, size=None, **kwargs):
    native.genrule(
        name = "create_empty_file",
        srcs = srcs,
        outs = ["tmp"],
        cmd = "echo 1 > $@",
        **kwargs,
    )
