"""A set of methods to build a smithy Cli command

These methods should be used in other build rules and are not intended 
for standalone use. 

"""

def base_build_cmd(ctx, discovery = True):
    gen_cmd = "{java_path} -jar {cli_jar} build".format(
        java_path = ctx.attr._jdk[java_common.JavaRuntimeInfo].java_executable_exec_path,
        cli_jar = ctx.file.smithy_cli.path,
    )

    # The -d option allows the cli to discover Smithy Models
    # in jars. It is required to add other smithy libraries
    if discovery:
        gen_cmd += " -d"

    return gen_cmd

# Selects a plugin to use for projection.
def add_plugin(ctx, gen_cmd, plugin):
    gen_cmd += " --plugin {plugin}".format(
        plugin = plugin,
    )

    return gen_cmd

# Selects a projection to build
def add_projection(ctx, gen_cmd):
    if ctx.attr.projection:
        gen_cmd += " --projection {projection}".format(
            projection = ctx.attr.projection,
        )

    return gen_cmd

def add_options(ctx, gen_cmd):
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

# Selects a smithy build json file to use for the build
def add_config(ctx, gen_cmd):
    gen_cmd += " -c {config}".format(
        config = ctx.file.config.path,
    )

    return gen_cmd

# add sources such as Model files for use in the build
def add_source_folder(ctx, gen_cmd):
    for file in ctx.files.srcs:
        gen_cmd += " {path}".format(path = file.path)

    return gen_cmd

# add dependencies to the build. These should typically be smithy
# library jars
def add_deps(ctx, gen_cmd):
    for file in ctx.files.deps:
        gen_cmd += " {path}".format(path = file.path)

    return gen_cmd

def generate_full_build_cmd(ctx, source_projection = False, plugin = None):
    base_cmd = base_build_cmd(ctx)

    if plugin:
        base_cmd = add_plugin(ctx, base_cmd, plugin)

    if not source_projection:
        base_cmd = add_projection(ctx, base_cmd)

    base_cmd = add_options(ctx, base_cmd)
    base_cmd = add_config(ctx, base_cmd)
    base_cmd = add_source_folder(ctx, base_cmd)
    base_cmd = add_deps(ctx, base_cmd)

    return base_cmd
