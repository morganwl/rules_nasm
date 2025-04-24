# Copyright (c) 2024 Morgan Wajda-Levie.

"""# rules_nasm

`nasm` is an assembler for the x86 architecture that recognizes a
variant of Intel assembly syntax, as opposed to the AT&T syntax
recognized by `gcc` and most other C compilers. `nasm` sources are
sometimes included in open-source software, such as
[ffmpeg](https://ffmpeg.org/).

`rules_nasm` provides an idiomatically consistent interface for
incorporating `nasm` sources into Bazel projects, although the current
implementation is incomplete.

## Setup

Add the following snippet to your `MODULE.bazel` file:

```python
bazel_dep(name = "rules_nasm", version = "{SEE_RELEASES}")

register_toolchains(
    "@rules_nasm//nasm/toolchain",
)
```

Note that toolchain registration can be updated to point to a custom toolchain
if users wish to have full control over the version of nasm used in different
configurations. See [nasm_toolchain](#nasm_toolchain) for more details on defining
toolchains.
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
