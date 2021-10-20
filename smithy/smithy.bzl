"""Bazel rules for generating smithy projections

"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_jar")

############################
## Initialization
## -------
## Pull down the the CLI jar file from a repository.
## This should be run in the WORKSPACE file
##
############################
_SUPPORTED_PROVIDERS = {
    "mellemahp": {
        "name": "smithy_cli",
        "versions": {
            "1.12.0": {
                "artifact": "smithy-cli.jar",
                "url": "https://github.com/mellemahp/smithy-cli-executable/releases/download/1.12.0/smithy_cli.jar",
                "sha": "f8d4921ae5a32567b3a7c3cf4895fdfbe1ff40c11b88fa962642b0f8a9d8b018",
            },
        },
    },
}

def smithy_cli_init(
        smithy_cli_version = "1.12.0",
        smithy_cli_provider = "mellemahp",
        prefix = "io_bazel_rules_smithy"):
    http_jar(
        name = prefix + "_" + _SUPPORTED_PROVIDERS[smithy_cli_provider]["name"],
        sha256 = _SUPPORTED_PROVIDERS[smithy_cli_provider]["versions"][smithy_cli_version]["sha"],
        url = _SUPPORTED_PROVIDERS[smithy_cli_provider]["versions"][smithy_cli_version]["url"],
    )

    native.bind(
        name = prefix + "/dependency/smithy-cli",
        actual = "@" + prefix + "_" + _SUPPORTED_PROVIDERS[smithy_cli_provider]["name"] + "//jar",
    )

############################
## Smithy Rules
## -------
## NOTE: A smithy-cli provider must have been initialized
##       before it is possible to run these
############################

def _base_cmd(ctx):
    return "java -jar {cli_jar} build -d".format(
        cli_jar = ctx.file.smithy_cli.path,
    )

def _add_projection(ctx, gen_cmd):
    # always add for projections
    gen_cmd += " --plugin openapi"

    if ctx.attr.projection:
        gen_cmd += " --projection {projection}".format(
            projection = ctx.attr.projection,
        )

    return gen_cmd

def _add_options(ctx, gen_cmd):
    if ctx.attr.severity:
        gen_cmd += " --severity {severity}".format(
            severity = ctx.attr.severity,
        )

    if ctx.attr.logging:
        gen_cmd += " --logging {logging}".format(
            logging = ctx.attr.logging,
        )

    if ctx.attr.debug:
        gen_cmd += " --debug"

    if ctx.attr.no_color:
        gen_cmd += " --no-color"

    if ctx.attr.force_color:
        gen_cmd += " --force-color"

    if ctx.attr.stacktrace:
        gen_cmd += " --stacktrace"

    return gen_cmd

def _add_config(ctx, gen_cmd):
    gen_cmd += " -c {config}".format(
        config = ctx.file.config.path,
    )

    return gen_cmd

def _add_source_folder(ctx, cmd):
    for file in ctx.files.srcs:
        cmd += " {path}".format(path = file.path)

    return cmd

def _add_deps(ctx, cmd):
    for file in ctx.files.deps:
        cmd += " {path}".format(path = file.path)

    return cmd

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
    base_cmd = _base_cmd(ctx)
    base_cmd = _add_options(ctx, base_cmd)
    base_cmd = _add_projection(ctx, base_cmd)
    base_cmd = _add_config(ctx, base_cmd)
    base_cmd = _add_source_folder(ctx, base_cmd)
    base_cmd = _add_deps(ctx, base_cmd)

    cmds = [base_cmd]
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

        # downstream dependencies
        "deps": attr.label_list(),

        # smithy source files
        "srcs": attr.label_list(),

        # smithy-build config json file
        "config": attr.label(
            mandatory = True,
            allow_single_file = True,
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

SMITHY_PREFIX = "./build/smithy/source/sources/"
META_PREFIX = "java/META-INF/smithy/"

def _impl_library(ctx):
    inputs = ctx.files.srcs + ctx.files.deps + [
        ctx.file.smithy_cli,
        ctx.file.config,
    ]
    base_cmd = _base_cmd(ctx)
    base_cmd = _add_options(ctx, base_cmd)
    base_cmd = _add_config(ctx, base_cmd)
    base_cmd = _add_source_folder(ctx, base_cmd)
    base_cmd = _add_deps(ctx, base_cmd)

    cmds = [base_cmd]

    inputs = ctx.files.srcs + ctx.files.deps + [
        ctx.file.smithy_cli,
        ctx.file.config,
    ]

    inlist = []

    # include auto-generated manifest file
    manifest_file = ctx.actions.declare_file(META_PREFIX + "manifest")
    outlist = [manifest_file]
    cmds.append("cp {inpath} {outpath}".format(
        inpath = SMITHY_PREFIX + "manifest",
        outpath = manifest_file.path,
    ))
    for file in ctx.files.srcs:
        path_model_relative = file.path.split(
            "{root}/".format(root = ctx.attr.root_dir),
            1,
        )[-1]
        inpath = SMITHY_PREFIX + path_model_relative
        outpath = META_PREFIX + path_model_relative
        inlist.append(inpath)
        outfile = ctx.actions.declare_file(outpath)
        outlist.append(outfile)

        cmds.append(
            "cp {inpath} {outpath}".format(
                inpath = inpath,
                outpath = outfile.path,
            ),
        )

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = outlist,
        command = " && ".join(cmds),
        progress_message = "generating files for smithy library",
        arguments = [],
    )

    return [DefaultInfo(files = depset(outlist))]

smithy_source = rule(
    attrs = {
        # root directory for model files
        "root_dir": attr.string(
            mandatory = True,
            default = "model",
        ),

        # downstream dependencies
        "deps": attr.label_list(),

        # smithy source files
        "srcs": attr.label_list(),

        # smithy-build config json file
        "config": attr.label(
            mandatory = True,
            allow_single_file = True,
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
    implementation = _impl_library,
)

def smithy_library(name, srcs, config, root_dir):
    smithy_source(
        name = name + "lib",
        srcs = srcs,
        config = config,
        root_dir = root_dir,
    )

    native.java_binary(
        name = name,
        main_class = "NotImportant",
        resources = [name + "lib"],
    )
