# Copyright (c) 2024 Morgan Wajda-Levie.

"""Nasm toolchain repo rules."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//nasm/private:urls.bzl", "NASM_URLS")

def nasm_declare_toolchain_repos(configurations, host_os):
    """Declare all nasm_toolchain repositories.

    Args:
        configurations: {(str, bool): _}, a set of version, require_source pairs.
        host_os: str, the detected host operating system

    Returns:
        [str], a list of toolchain repository names.
    """
    toolchains = []
    for version, require_source in configurations:
        repo_name = nasm_declare_repo(version, require_source, host_os)
        toolchains.append(repo_name)
    return toolchains

def canonical_name(version, source, os):
    """Get canonical name for toolchain repository."""
    name = "%s_%s_%s"%(os, version, source)
    return name.lower().replace(" ", "")

def nasm_declare_repo(version, require_source, os):
    """Declare a nasm repository."""
    if os == "mac os x" and not require_source:
        url, checksum = nasm_get_url(version, os)
        if checksum:
            name = canonical_name(version, "binary", os)
            nasm_declare_repo_macosx(name, version, url, checksum)
            return name
    url, checksum = nasm_get_url(version, "source")
    if checksum == None:
        fail("No nasm release found for %s, %s."%(version, os))
    name = canonical_name(version, "source", os)
    nasm_declare_repo_source(name, version, url, checksum)
    return name

def nasm_define_toolchain(name):
    """Define a toolchain rule based on a toolchain name."""
    os = name.split("_")[0]
    toolchain_label = "@{name}//:toolchain_impl".format(name = name)
    rule = """\
toolchain(
    name = "{name}_toolchain",
    toolchain = "{toolchain_label}",
    toolchain_type = "{toolchain_type}",
    exec_compatible_with = [
        "@platforms//os:{os}",
    ],
)
    """.format(
        name = name,
        toolchain_label = toolchain_label,
        toolchain_type = Label("//nasm:toolchain_type"),
        os = os,
    )
    return rule

def _nasm_toolchains_impl(rctx):
    toolchains = [nasm_define_toolchain(tc) for tc in rctx.attr.toolchains]
    rctx.file(
        "BUILD.bazel",
        "\n\n".join(toolchains)
    )

nasm_toolchains = repository_rule(
    implementation = _nasm_toolchains_impl,
    attrs = {
        "toolchains": attr.string_list()
    }
)

def nasm_get_url(version, platform):
    """Get the URL and checksum for a version."""
    if platform == "mac os x":
        url = "https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/macosx/nasm-{}-macosx.zip"%version
    else:
        url = "https://www.nasm.us/pub/nasm/releasebuilds/%s/nasm-%s.tar.gz"%(version, version)
    return url, NASM_URLS.get(url, None)

def nasm_declare_repo_source(name, version, url, checksum):
    """Declare a nasm repository to be built from source."""
    http_archive(
        name = name,
        build_file = Label("//third_party/nasm:source.BUILD"),
        url = url,
        patches = [Label("//nasm/toolchain:ver.patch")],
        patch_args = ["-p1"],
        strip_prefix = "nasm-%s"%version,
        sha256 = checksum,
    )

def nasm_declare_repo_macosx(name, version, url, checksum):
    """Declare a nasm repository with MacOS executable."""
    http_archive(
        name = name,
        build_file = Label("//third_party/nasm:macosx.BUILD"),
        url = url,
        strip_prefix = "nasm-{}"%version,
        sha256 = checksum,
    )


def nasm_fetch_toolchains():
    """Fetch toolchain dependencies."""
    nasm_fetch_toolchains_macosx("nasm_macosx")
    nasm_fetch_toolchains_source("nasm_source")

def nasm_fetch_toolchains_macosx(name):
    http_archive(
        name = name,
        build_file = Label("//third_party/nasm:macosx.BUILD"),
        url = "https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/macosx/nasm-2.16.03-macosx.zip",
        strip_prefix = "nasm-2.16.03",
        sha256 = "0d29bcd8a5fc617333f4549c7c1f93d1866a4a0915c40359e0a8585bb1a5aa75",
    )

def nasm_fetch_toolchains_source(name):
    http_archive(
        name = name,
        build_file = Label("//third_party/nasm:source.BUILD"),
        url = "https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.gz",
        patches = [Label("//nasm/toolchain:ver.patch")],
        patch_args = ["-p1"],
        strip_prefix = "nasm-2.16.03",
        sha256 = "5bc940dd8a4245686976a8f7e96ba9340a0915f2d5b88356874890e207bdb581",
    )

def nasm_register_toolchains():
    nasm_fetch_toolchains()
    native.register_toolchains("@rules_nasm//nasm:all")
