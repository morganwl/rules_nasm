"""Rules for running executables as tests"""

def _native_test_impl(ctx):
    executable = ctx.executable.executable
    link = ctx.actions.declare_file("{}.{}".format(ctx.label.name, executable.extension).rstrip("."))
    ctx.actions.symlink(
        output = link,
        target_file = executable,
        is_executable = True,
    )

    return [DefaultInfo(
        files = depset([link]),
        executable = link,
        runfiles = ctx.runfiles([link]).merge(ctx.attr.executable[DefaultInfo].default_runfiles),
    )]

native_test = rule(
    doc = "Run a given executable as a test.",
    implementation = _native_test_impl,
    attrs = {
        "executable": attr.label(
            doc = "The executable to run",
            cfg = "target",
            executable = True,
            mandatory = True,
        ),
    },
    test = True,
)
