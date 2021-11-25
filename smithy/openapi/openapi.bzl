"""Bazel rules for generating OpenApi specs from a smithy projection

"""

load("//smithy:common.bzl", "generate_full_build_cmd")

def _generate_projection_extraction_cmd(ctx):
    return "cp build/smithy/{projection}/openapi/{service}.openapi.json {output}".format(
        projection = ctx.attr.projection,
        service = ctx.attr.service_name,
        output = ctx.outputs.openapi.path,
    )

def _impl_openapi(ctx):
    inputs = ctx.files.srcs + ctx.files.deps + [
        ctx.file.smithy_cli,
        ctx.file.config,
    ]

    cmds = [generate_full_build_cmd(ctx, plugin = "openapi")]
    cmds += [_generate_projection_extraction_cmd(ctx)]

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = [ctx.outputs.openapi],
        command = " && ".join(cmds),
        progress_message = "generating openapi for smithy projection %s" % ctx.attr.projection,
        arguments = [],
    )

    return struct(
        openapi = ctx.outputs.openapi,
    )

smithy_openapi = rule(
    attrs = {
        "service_name": attr.string(
            mandatory = True,
        ),

        # upstream smithy library dependencies
        "deps": attr.label_list(
            allow_files = [".jar"],
        ),

        # smithy source files
        "srcs": attr.label_list(
            allow_files = [
                ".smithy",
                ".json",
            ],
        ),

        # smithy-build config json file
        "config": attr.label(
            mandatory = True,
            allow_single_file = [
                ".json",
            ],
        ),

        # cli options
        "projection": attr.string(
            mandatory = True,
        ),
        "severity": attr.string(),
        "logging": attr.string(default = "INFO"),

        # cli flags
        "debug": attr.bool(),
        "no_color": attr.bool(),
        "force_color": attr.bool(),
        "stacktrace": attr.bool(),

        # JDK to use for executing JAR file
        "smithy_cli": attr.label(
            cfg = "host",
            default = Label("//external:io_bazel_rules_smithy/dependency/smithy-cli"),
            allow_single_file = True,
        ),
    },
    outputs = {
        "openapi": "%{name}.openapi.json",
    },
    implementation = _impl_openapi,
)
