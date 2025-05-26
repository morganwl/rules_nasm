load(
    "//nasm/private:cc_rules.bzl",
    _nasm_cc_test = "nasm_cc_test",
)

def nasm_cc_test(**kwargs):
    _nasm_cc_test(**kwargs)
