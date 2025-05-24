load(
    "//nasm/private:nasm_toolchain.bzl",
    _nasm_toolchain = "nasm_toolchain",
)

def nasm_toolchain(**kwargs):
    _nasm_toolchain(**kwargs)
