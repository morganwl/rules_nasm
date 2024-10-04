# Copyright (c) 2024 Morgan Wajda-Levie.

"""Nasm toolchain repo rules."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def nasm_fetch_toolchains():
    """Fetch toolchain dependencies."""
    nasm_fetch_toolchains_macosx("nasm_macosx")
    nasm_fetch_toolchains_source("nasm_source")

def nasm_fetch_toolchains_macosx(name):
    http_archive(
        name = name,
        build_file = "//third_party/nasm:macosx.BUILD",
        url = "https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/macosx/nasm-2.16.03-macosx.zip",
        strip_prefix = "nasm-2.16.03",
        sha256 = "0d29bcd8a5fc617333f4549c7c1f93d1866a4a0915c40359e0a8585bb1a5aa75",
    )

def nasm_fetch_toolchains_source(name):
    http_archive(
        name = name,
        build_file = "//third_party/nasm:source.BUILD",
        url = "https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.gz",
        patches = ["//nasm/toolchain:ver.patch"],
        patch_args = ["-p1"],
        strip_prefix = "nasm-2.16.03",
        sha256 = "5bc940dd8a4245686976a8f7e96ba9340a0915f2d5b88356874890e207bdb581",
    )

def nasm_register_toolchains():
    nasm_fetch_toolchains()
    native.register_toolchains("//nasm:all")
