load("@rules_foreign_cc//foreign_cc:defs.bzl", "configure_make")
load("@rules_nasm//nasm:nasm_toolchain.bzl", "nasm_toolchain")

filegroup(
    name = "nasm_src",
    srcs = glob(include=["**/*"], exclude=["*.BUILD"]),
)

configure_make(
    name = "make_nasm",
    lib_source = ":nasm_src",
    autogen = True,
    configure_in_place = True,
    targets = [
        "",
        "install",
    ],
    out_binaries = [
        "nasm",
        "ndisasm",
    ],
)

filegroup(
    name = "nasm_bin",
    srcs = [":make_nasm",],
    output_group = "nasm",
)

genrule(
    name = "assembler",
    srcs = [":nasm_bin"],
    outs = ["nasm"],
    cmd = "cp $< $@",
    executable = True,
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
