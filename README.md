# Netwide Assembly rules for Bazel

![Testing status](https://github.com/morganwl/rules_nasm/actions/workflows/tests.yaml/badge.svg)

Ruleset and toolchain for assembling Netwide Assembly (nasm) sources in
Bazel.

This is an early release, and is provided without assurances.
Contributions, feedback, and bug reports are welcome.

## Why rules_nasm?

An existing module, [nasm](https://registry.bazel.build/modules/nasm),
is available from the [Bazel Central Registry](https://registry.bazel.build).
This module provides a target for building a specific version of`nasm`,
and may be sufficient for many use cases.

rules_nasm aims to provide a fully functional module for creating
netwide assembly targets in Bazel. This allows netwide assembly targets
to be used as self-contained executables, or as dependencies for C and
C++ toolchains, without creating custom rules or macros.

## Supported platforms

The following platforms are currently supported:

- Linux x86-64
- MacOS x86-64

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

## Known Issues

Bugs, known issues, and planned features are documented in
[Issues](issues). Additional issue reports are welcome.
