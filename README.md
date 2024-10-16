# Netwide Assembly rules for Bazel

![Testing status](https://github.com/morganwl/rules_nasm/actions/workflows/tests.yaml/badge.svg)

Rules and toolchains for assembling Netwide Assembly (nasm) sources in
Bazel.

This is a minimally functional proof of concept and is provided without
assurances. Contributions, feedback, and bug reports are welcome.

## Getting Started

*(Support for projects not using `bzlmod` will be added in a future
release.)*

If you are using `bzlmod`, add the following to `MODULE.bazel`:

```starlark
bazel_dep(name = "rules_nasm", version = "0.1.0")

# configure the toolchain
nasm = use_extension("@rules_nasm//nasm:extensions.bzl", "nasm")
nasm.toolchain(
    nasm_version = "2.16.03",
)
```

If you are not using `bzlmod`, add the following to `WORKSPACE`:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_nasm",
    sha256 = "<unknown>",
    strip_prefix = "rules_nasm-0.1.0",
    url = "https://github.com/morganwl/rules_nasm/releases/...",
)

load("@rules_nasm//nasm:deps.bzl", "rules_nasm_dependencies",
"nasm_toolchain", "nasm_register_toolchains")

rules_nasm_dependencies()

nasm_toolchain(
    name = "nasm_toolchain",
    nasm_version = "2.16.03",
)

nasm_register_toolchains()
```

## Usage
