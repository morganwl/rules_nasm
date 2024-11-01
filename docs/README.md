# Documentation for rules_nasm


`nasm` is an assembler for the x86 architecture that recognizes a
variant of Intel assembly syntax, as opposed to the AT&T syntax
recognized by `gcc` and most other C compilers. `nasm` sources are
sometimes included in open-source software, such as
[ffmpeg](https://ffmpeg.org/).

`rules_nasm` provides an idiomatically consistent interface for
incorporating `nasm` sources into Bazel projects, although the current
implementation is incomplete.

<a id="nasm_binary"></a>

## nasm_binary

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_binary")

nasm_binary(<a href="#nasm_binary-name">name</a>, <a href="#nasm_binary-src">src</a>, <a href="#nasm_binary-hdrs">hdrs</a>, <a href="#nasm_binary-preincs">preincs</a>, <a href="#nasm_binary-includes">includes</a>, <a href="#nasm_binary-kwargs">kwargs</a>)
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
| <a id="nasm_binary-name"></a>name |  A unique name for this target.   |  none |
| <a id="nasm_binary-src"></a>src |  The assembly source file.   |  none |
| <a id="nasm_binary-hdrs"></a>hdrs |  Other assembly sources which may be included by `src`. preincs: Assembly sources which will be included and processed before the source file. Sources will be included in the order listed.   |  `None` |
| <a id="nasm_binary-preincs"></a>preincs |  Assembly sources which will be included and processed before the source file. Sources will be included in the order listed.   |  `None` |
| <a id="nasm_binary-includes"></a>includes |  Directories which will be added to the search path for include files.   |  `None` |
| <a id="nasm_binary-kwargs"></a>kwargs |  Additional keyword arguments passed to the `cc_binary` rule.   |  none |


<a id="nasm_library"></a>

## nasm_library

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_library")

nasm_library(<a href="#nasm_library-name">name</a>, <a href="#nasm_library-src">src</a>, <a href="#nasm_library-hdrs">hdrs</a>, <a href="#nasm_library-preincs">preincs</a>, <a href="#nasm_library-includes">includes</a>, <a href="#nasm_library-kwargs">kwargs</a>)
</pre>

Assemble an `nasm` source for use as a C++ dependency.

Assembled object files should be usable as C compilation units.
Rather than create a `CcInfo` object directly, we pass the assembled
object file as the src to a `cc_library` rule, which creates a
corresponding provider, and captures any additional dependencies.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nasm_library-name"></a>name |  A unique name for this target.   |  none |
| <a id="nasm_library-src"></a>src |  The assembly source file.   |  none |
| <a id="nasm_library-hdrs"></a>hdrs |  Other assembly sources which may be included by `src`.   |  `None` |
| <a id="nasm_library-preincs"></a>preincs |  Assembly sources which will be included and processed before the source file. Sources will be included in the order listed.   |  `None` |
| <a id="nasm_library-includes"></a>includes |  Directories which will be added to the search path for include files.   |  `None` |
| <a id="nasm_library-kwargs"></a>kwargs |  Additional keyword arguments passed to the `cc_library` rule.   |  none |


<a id="nasm_test"></a>

## nasm_test

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_test")

nasm_test(<a href="#nasm_test-name">name</a>, <a href="#nasm_test-src">src</a>, <a href="#nasm_test-size">size</a>, <a href="#nasm_test-hdrs">hdrs</a>, <a href="#nasm_test-preincs">preincs</a>, <a href="#nasm_test-includes">includes</a>, <a href="#nasm_test-kwargs">kwargs</a>)
</pre>

Assemble and execute a test assembly program.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nasm_test-name"></a>name |  A unique name for this target.   |  none |
| <a id="nasm_test-src"></a>src |  The assembly source file.   |  none |
| <a id="nasm_test-size"></a>size |  The "heaviness" of a test target. See [Bazel reference](https://bazel.build/reference/be/common-definitions#test.size) for details.   |  `None` |
| <a id="nasm_test-hdrs"></a>hdrs |  Other assembly sources which may be included by `src`. preincs: Assembly sources which will be included and processed before the source file. Sources will be included in the order listed.   |  `None` |
| <a id="nasm_test-preincs"></a>preincs |  Assembly sources which will be included and processed before the source file. Sources will be included in the order listed.   |  `None` |
| <a id="nasm_test-includes"></a>includes |  Directories which will be added to the search path for include files.   |  `None` |
| <a id="nasm_test-kwargs"></a>kwargs |  Additional keyword arguments passed to the `cc_test` rule.   |  none |


