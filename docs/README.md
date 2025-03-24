# Documentation for rules_nasm


`nasm` is an assembler for the x86 architecture that recognizes a
variant of Intel assembly syntax, as opposed to the AT&T syntax
recognized by `gcc` and most other C compilers. `nasm` sources are
sometimes included in open-source software, such as
[ffmpeg](https://ffmpeg.org/).

`rules_nasm` provides an idiomatically consistent interface for
incorporating `nasm` sources into Bazel projects, although the current
implementation is incomplete.

<a id="nasm_library"></a>

## nasm_library

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_library")

nasm_library(<a href="#nasm_library-name">name</a>, <a href="#nasm_library-srcs">srcs</a>, <a href="#nasm_library-hdrs">hdrs</a>, <a href="#nasm_library-copts">copts</a>, <a href="#nasm_library-includes">includes</a>, <a href="#nasm_library-preincs">preincs</a>)
</pre>

Assemble an `nasm` source for use as a C++ dependency.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nasm_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nasm_library-srcs"></a>srcs |  The assembly source file. Must have an extension of .asm, .nasm, .s, .i.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nasm_library-hdrs"></a>hdrs |  Other assembly sources which may be included by `src`. Must have an extension of .asm, .nasm, .s, .i.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nasm_library-copts"></a>copts |  Additional compilation flags to `nasm`.   | List of strings | optional |  `[]`  |
| <a id="nasm_library-includes"></a>includes |  Directories which will be added to the search path for include files.   | List of strings | optional |  `[]`  |
| <a id="nasm_library-preincs"></a>preincs |  Assembly sources which will be included and processed before the source file. Sources will be included in the order listed. Must have an extension of .asm, .nasm, .s, .i.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="nasm_toolchain"></a>

## nasm_toolchain

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_toolchain")

nasm_toolchain(<a href="#nasm_toolchain-name">name</a>, <a href="#nasm_toolchain-copts">copts</a>, <a href="#nasm_toolchain-nasm">nasm</a>)
</pre>

A toolchain for configuring `nasm` rules.

A toolchain can be defined by adding a snippet like the following
somewhere in a `BUILD.bazel` file within your workspace.

```python
load("@rules_nasm//nasm:defs.bzl", "nasm_toolchain")

nasm_toolchain(
    name = "nasm_toolchain",
    copts = select({
        "//nasm:elf64": ["-felf64"],
        "//nasm:macho64": ["-fmacho64"],
        "//conditions:default": [],
    }),
    nasm = "@nasm",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "toolchain",
    toolchain = ":nasm_toolchain",
    toolchain_type = "@rules_nasm//nasm:toolchain_type",
    visibility = ["//visibility:public"],
)
```

Once the toolchain is defined, it will need to be registered in the `MODULE.bazel` file.

```python
register_toolchains("//:nasm_toolchain")
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nasm_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nasm_toolchain-copts"></a>copts |  Default arguments to pass to the `nasm` executable.   | List of strings | optional |  `[]`  |
| <a id="nasm_toolchain-nasm"></a>nasm |  The `nasm` executable.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="nasm_cc_binary"></a>

## nasm_cc_binary

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_cc_binary")

nasm_cc_binary(*, <a href="#nasm_cc_binary-name">name</a>, <a href="#nasm_cc_binary-srcs">srcs</a>, <a href="#nasm_cc_binary-hdrs">hdrs</a>, <a href="#nasm_cc_binary-preincs">preincs</a>, <a href="#nasm_cc_binary-includes">includes</a>, <a href="#nasm_cc_binary-kwargs">**kwargs</a>)
</pre>

Assemble a source file as an executable.

Assembles an `nasm` source file as an executable binary. The
assembled object file will be linked against the C standard library,
meaning that it must define a starting function with the label
expected by system libraries, can reference C standard library
functions, and must not export labels which conflict with the C
standard library.

*(Standalone binaries which are not linked to standard libraries are
planned for a future release.)*

**NB**: The mangling of function labels is defined by the ABI of the
target platform. Some degree of portability can be ensured by using
a macro to define global labels, and deduce the target platform by
inspecting the target binary format.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nasm_cc_binary-name"></a>name |  A unique name for this target.   |  none |
| <a id="nasm_cc_binary-srcs"></a>srcs |  The assembly source files.   |  none |
| <a id="nasm_cc_binary-hdrs"></a>hdrs |  Other assembly sources which may be included by `srcs`.   |  `None` |
| <a id="nasm_cc_binary-preincs"></a>preincs |  Assembly sources which will be included and processed before the source file. Sources will be included in the order listed.   |  `None` |
| <a id="nasm_cc_binary-includes"></a>includes |  Directories which will be added to the search path for include files.   |  `None` |
| <a id="nasm_cc_binary-kwargs"></a>kwargs |  Additional keyword arguments passed to the `cc_binary` rule.   |  none |


<a id="nasm_cc_library"></a>

## nasm_cc_library

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_cc_library")

nasm_cc_library(*, <a href="#nasm_cc_library-name">name</a>, <a href="#nasm_cc_library-srcs">srcs</a>, <a href="#nasm_cc_library-hdrs">hdrs</a>, <a href="#nasm_cc_library-preincs">preincs</a>, <a href="#nasm_cc_library-includes">includes</a>, <a href="#nasm_cc_library-kwargs">**kwargs</a>)
</pre>

Assemble an `nasm` source for use as a C++ dependency.

Assembled object files should be usable as C compilation units.
Rather than create a `CcInfo` object directly, we pass the assembled
object file as the src to a `cc_library` rule, which creates a
corresponding provider, and captures any additional dependencies.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nasm_cc_library-name"></a>name |  A unique name for this target.   |  none |
| <a id="nasm_cc_library-srcs"></a>srcs |  The assembly source files.   |  none |
| <a id="nasm_cc_library-hdrs"></a>hdrs |  Other assembly sources which may be included by `srcs`.   |  `None` |
| <a id="nasm_cc_library-preincs"></a>preincs |  Assembly sources which will be included and processed before the source file. Sources will be included in the order listed.   |  `None` |
| <a id="nasm_cc_library-includes"></a>includes |  Directories which will be added to the search path for include files.   |  `None` |
| <a id="nasm_cc_library-kwargs"></a>kwargs |  Additional keyword arguments passed to the `cc_library` rule.   |  none |


<a id="nasm_cc_test"></a>

## nasm_cc_test

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_cc_test")

nasm_cc_test(*, <a href="#nasm_cc_test-name">name</a>, <a href="#nasm_cc_test-srcs">srcs</a>, <a href="#nasm_cc_test-size">size</a>, <a href="#nasm_cc_test-hdrs">hdrs</a>, <a href="#nasm_cc_test-preincs">preincs</a>, <a href="#nasm_cc_test-includes">includes</a>, <a href="#nasm_cc_test-kwargs">**kwargs</a>)
</pre>

Assemble and execute a test assembly program.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nasm_cc_test-name"></a>name |  A unique name for this target.   |  none |
| <a id="nasm_cc_test-srcs"></a>srcs |  The assembly source files.   |  none |
| <a id="nasm_cc_test-size"></a>size |  The "heaviness" of a test target. See [Bazel reference](https://bazel.build/reference/be/common-definitions#test.size) for details.   |  `None` |
| <a id="nasm_cc_test-hdrs"></a>hdrs |  Other assembly sources which may be included by `srcs`.   |  `None` |
| <a id="nasm_cc_test-preincs"></a>preincs |  Assembly sources which will be included and processed before the source file. Sources will be included in the order listed.   |  `None` |
| <a id="nasm_cc_test-includes"></a>includes |  Directories which will be added to the search path for include files.   |  `None` |
| <a id="nasm_cc_test-kwargs"></a>kwargs |  Additional keyword arguments passed to the `cc_test` rule.   |  none |


