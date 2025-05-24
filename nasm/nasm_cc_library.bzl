load(
    "//nasm/private:cc_rules.bzl",
    _nasm_cc_library = "nasm_cc_library",
)

def nasm_cc_library(**kwargs):
    _nasm_cc_library(**kwargs)
