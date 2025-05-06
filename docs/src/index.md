# Netwide Assembly rules for Bazel

![Testing status](https://github.com/morganwl/rules_nasm/actions/workflows/tests.yaml/badge.svg)

Ruleset and toolchain for assembling Netwide Assembly (nasm) sources in
Bazel.

This is an early release, and is provided without assurances.
Contributions, feedback, and bug reports are welcome.

## Getting Started

Add the following snippet to your `MODULE.bazel` file:

```python
bazel_dep(name = "rules_nasm", version = "{SEE_RELEASES}")

register_toolchains(
    "@rules_nasm//nasm/toolchain",
)
```

See the [release notes](https://github.com/morganwl/rules_nasm/releases)
for getting started with the latest version.

Note that toolchain registration can be updated to point to a custom toolchain
if users wish to have full control over the version of nasm used in different
configurations. See [nasm_toolchain](./rules.md#nasm_toolchain) for more details on defining
toolchains.

## Supported platforms

The following platforms are currently supported:

- Linux x86_64
- MacOS x86_64
- Windows x86_64

## Known Issues

Bugs, known issues, and planned features are documented in
[Issues](https://github.com/morganwl/rules_nasm/issues). Additional
issue reports are welcome.
