"""Bazel rule for generating smithy source projections

This rule is mostly used for constructing smithy library jars

"""

load("//smithy:common.bzl", "generate_full_build_cmd", "get_filters")

SMITHY_PREFIX = "./build/smithy/source/sources/"
META_PREFIX = "java/META-INF/smithy/"
# Required to prevent collision between rules
OUT_DIR_SUFFIX = "buildDir"
SMITHY_FILTER_SUFFIX = ".smithy"

def _add_manifest_file(ctx, out_dir, cmds):
    # include auto-generated manifest file
    manifest_file = ctx.actions.declare_file(
        out_dir + META_PREFIX + "manifest"
    )
    outlist = [manifest_file]
    cmds.append("cp {inpath} {outpath}".format(
        inpath = SMITHY_PREFIX + "manifest",
        outpath = manifest_file.path,
    ))

    return cmds, outlist

def _extract_relative_paths(ctx, out_dir, cmds, outlist):
    for file in ctx.files.srcs:
        # ignore any files in the filter list
        if not file.basename in get_filters(ctx, ctx.attr.filters):
            # the source projection flattens all of the output paths
            path_model_relative = file.path.split(
                "{root}/".format(root = ctx.attr.root_dir),
                1,
            )[-1].split("/")[-1]
            inpath = SMITHY_PREFIX + path_model_relative
            outpath = out_dir + META_PREFIX + path_model_relative
            outfile = ctx.actions.declare_file(outpath)
            outlist.append(outfile)

            cmds.append(
                "cp {inpath} {outpath}".format(
                    inpath = inpath,
                    outpath = outfile.path,
                ),
            )

    return cmds, outlist

def _impl_source_projection(ctx):
    inputs = ctx.files.srcs + ctx.files.deps + [
        ctx.file.smithy_cli,
        ctx.file.config,
    ]

    # create output directory to prevent collisions between rules
    out_dir = ctx.attr.name + OUT_DIR_SUFFIX + "/"

    cmds = [generate_full_build_cmd(ctx, source_projection = True, filters=ctx.attr.filters)]
    cmds, outlist = _add_manifest_file(ctx, out_dir, cmds)
    cmds, outlist = _extract_relative_paths(ctx, out_dir, cmds, outlist)

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = outlist,
        command = " && ".join(cmds),
        progress_message = "generating files for smithy library",
        arguments = [],
        tools = ctx.files._jdk,
    )

    return [DefaultInfo(files = depset(outlist))]

smithy_source_projection = rule(
    attrs = {
        # root directory for model files
        "root_dir": attr.string(
            default = "model",
        ),

        # upstream dependencies
        "deps": attr.label_list(
            allow_files = [
                ".jar",
            ],
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
        "severity": attr.string(),
        "logging": attr.string(default = "INFO"),

        # cli flags
        "debug": attr.bool(),
        "no_color": attr.bool(),
        "force_color": attr.bool(),
        "stacktrace": attr.bool(),
        "quiet": attr.bool(),

        # filter out files from projection
        "filters": attr.string_list(),

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
    implementation = _impl_source_projection,
)
