# Copyright (c) 2024 Morgan Wajda-Levie.

"""# rules_nasm

Bazel rules for Netwide Assembly (nasm).
"""

load(
    "//nasm/private:cc_rules.bzl",
    _nasm_cc_binary = "nasm_cc_binary",
    _nasm_cc_library = "nasm_cc_library",
    _nasm_cc_test = "nasm_cc_test",
)
load(
    "//nasm/private:nasm_toolchain.bzl",
    _nasm_toolchain = "nasm_toolchain",
)
load(
    "//nasm/private/rules:library.bzl",
    _nasm_library = "nasm_library",
)

nasm_library = _nasm_library
nasm_toolchain = _nasm_toolchain

nasm_cc_test = _nasm_cc_test
nasm_cc_library = _nasm_cc_library
nasm_cc_binary = _nasm_cc_binary
