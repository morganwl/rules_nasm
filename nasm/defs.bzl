# Copyright (c) 2024 Morgan Wajda-Levie.

"""Public rules definitions for nasm."""

load("//nasm/private/rules:library.bzl", _nasm_library = "nasm_library")
load("//nasm/private/rules:test.bzl", _nasm_test = "nasm_test")
load("//nasm/private/rules:binary.bzl", _nasm_binary = "nasm_binary")

nasm_test = _nasm_test
nasm_library = _nasm_library
nasm_binary = _nasm_binary
