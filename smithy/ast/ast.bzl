"""Bazel rules for generating JSON Ast from a smithy library

"""
load("//smithy:common.bzl", "generate_full_build_cmd")

def _generate_ast_extraction_cmd(ctx):
    return "cp build/smithy/{projection}/{projection}/{projection}.json {output}".format(
        projection = ctx.attr.projection,
        output = ctx.outputs.ast.path,
    )

def _impl_smithy_ast(ctx):
    inputs = ctx.files.srcs + ctx.files.deps + [
        ctx.file.smithy_cli,
        ctx.file.config,
    ]

    cmds = [generate_full_build_cmd(ctx)]
    cmds += [_generate_ast_extraction_cmd(ctx)]

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = [ctx.outputs.ast],
        command = " && ".join(cmds),
        progress_message = "extracting ast for smithy projection %s" % ctx.attr.projection,
        arguments = [],
        tools = ctx.files._jdk,
    )

    return struct(ast = ctx.outputs.ast)

smithy_ast = rule(
    attrs = {
        # smithy source files
        "srcs": attr.label_list(
            allow_files = [
                ".smithy"
            ],
        ),

        # upstream dependencies
        "deps": attr.label_list(
            allow_files = [
                ".jar",
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
        "logging": attr.string(default = "INFO"),
        "severity": attr.string(),

        # cli flags
        "debug": attr.bool(),
        "no_color": attr.bool(),
        "force_color": attr.bool(),
        "stacktrace": attr.bool(),
        "quiet": attr.bool(),

        # JDK to use for executing smithy cli jar
        "_jdk": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
            providers = [java_common.JavaRuntimeInfo],
        ),

        # Smithy CLI to use
        "smithy_cli": attr.label(
            cfg = "host",
            default = Label("//external:io_bazel_rules_smithy/dependency/smithy-cli"),
            allow_single_file = True,
        ),
    },
    outputs = {
        "ast": "%{name}.ast.json",
    },
    implementation = _impl_smithy_ast,
)