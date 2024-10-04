load("@rules_foreign_cc//foreign_cc:defs.bzl", "configure_make")

filegroup(
    name = "nasm_src",
    srcs = glob(include=["**/*"], exclude=["*.BUILD"]),
)

configure_make(
    name = "make_nasm",
    lib_source = ":nasm_src",
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
    name = "nasm",
    srcs = [":nasm_bin"],
    outs = ["nasm"],
    cmd = "cp $< $@",
    executable = True,
    visibility = ["//visibility:public"],
)
