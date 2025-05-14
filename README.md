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

## Getting Started

For usage and setup instructions, please see: <https://morganwl.github.io/rules_nasm/>
