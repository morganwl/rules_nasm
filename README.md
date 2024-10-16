# Netwide Assembly rules for Bazel

![Testing status](https://github.com/morganwl/rules_nasm/actions/workflows/tests.yaml/badge.svg)

Rules and toolchains for assembling Netwide Assembly (nasm) sources in
Bazel.

Currently supports Linux x86-64 and Mac x86-64.

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

## Usage

A toolchain dependency must be explicitly specified in order to use the
`nasm` rules. The toolchain configuration will look for an existing
binary of the desired version; if none exists, the assembler will be
built from source.

`@nasm:defs.bzl` exposes three rules: `nasm_test`, `nasm_library` and
`nasm_binary`. `nasm_library` can be used as a dependency for the cc
toolchain.

The target `@nasm:assembler` can be used to expose the path to the
currently configured assembler executable.
