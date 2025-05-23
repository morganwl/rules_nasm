load(
    "//nasm/private:cc_rules.bzl",
    _nasm_cc_binary = "nasm_cc_binary",
)

def nasm_cc_binary(**kwargs):
    _nasm_cc_binary(**kwargs)
