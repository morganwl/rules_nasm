load(
    "//nasm/private/rules:library.bzl",
    _nasm_library = "nasm_library",
)

def nasm_library(**kwargs):
    _nasm_library(**kwargs)
