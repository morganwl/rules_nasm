<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public rules definitions for nasm.

<a id="nasm_binary"></a>

## nasm_binary

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_binary")

nasm_binary(<a href="#nasm_binary-name">name</a>, <a href="#nasm_binary-src">src</a>, <a href="#nasm_binary-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nasm_binary-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="nasm_binary-src"></a>src |  <p align="center"> - </p>   |  none |
| <a id="nasm_binary-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="nasm_library"></a>

## nasm_library

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_library")

nasm_library(<a href="#nasm_library-name">name</a>, <a href="#nasm_library-src">src</a>, <a href="#nasm_library-kwargs">kwargs</a>)
</pre>

Wrap nasm_library with a CC provider.

Assembled object files should be usable as C compilation units.
Rather than create a CcInfo object directly, we pass the assembled
object file as the src to a cc_library rule, which creates a
corresponding provider, and captures any additional dependencies.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nasm_library-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="nasm_library-src"></a>src |  <p align="center"> - </p>   |  none |
| <a id="nasm_library-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="nasm_test"></a>

## nasm_test

<pre>
load("@rules_nasm//nasm:defs.bzl", "nasm_test")

nasm_test(<a href="#nasm_test-name">name</a>, <a href="#nasm_test-src">src</a>, <a href="#nasm_test-size">size</a>, <a href="#nasm_test-kwargs">kwargs</a>)
</pre>

Assemble and execute a test assembly program.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nasm_test-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="nasm_test-src"></a>src |  <p align="center"> - </p>   |  none |
| <a id="nasm_test-size"></a>size |  <p align="center"> - </p>   |  `None` |
| <a id="nasm_test-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


