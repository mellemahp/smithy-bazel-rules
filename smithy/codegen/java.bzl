"""Bazel rules for generating Java models from smithy model

"""

load("//smithy:smithy.bzl", "smithy_openapi")
load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_generator")

def _impl_extract_java_models_from_openapi_codegen(ctx):
    java_runtime = ctx.attr._jdk[java_common.JavaRuntimeInfo]
    jar_path = "%s/bin/jar" % java_runtime.java_home

    cmd = "%s cf" % jar_path

    # add output jar file path
    cmd += " %s" % ctx.outputs.model_jar.path

    # select the path of the code gen output
    cmd += " -C %s/src/main/java/" % ctx.file.src.path

    # add namespace of file
    cmd += " %s" % "/".join(ctx.attr.model_package.split("."))

    ctx.actions.run_shell(
        inputs = ctx.files._jdk + [ctx.file.src],
        outputs = [ctx.outputs.model_jar],
        command = cmd,
    )

    return struct(
        model_jar = ctx.outputs.model_jar,
    )

extract_java_models_from_openapi_codegen = rule(
    attrs = {
        # output of openapi code gen
        "src": attr.label(mandatory = True, allow_single_file = True),

        # namespace of model package
        "model_package": attr.string(mandatory = True),
        "_jdk": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
            providers = [java_common.JavaRuntimeInfo],
        ),
    },
    outputs = {
        "model_jar": "%{name}_models.jar",
    },
    implementation = _impl_extract_java_models_from_openapi_codegen,
)

def smithy_java_models(name, srcs, config, projection, service_name, model_namespace, deps, gen_library = "feign"):
    smithy_openapi(
        name = "{name}_smithy_openapi".format(name = name),
        srcs = srcs,
        config = config,
        projection = projection,
        service_name = service_name,
        deps = deps,
    )

    openapi_generator(
        name = "{name}_codegen".format(name = name),
        additional_properties = {
            "library": gen_library,
        },
        generator = "java",
        model_package = model_namespace,
        spec = "{name}_smithy_openapi".format(name = name),
        system_properties = {
            "models": "",
            "modelDocs": "false",
            "apiTests": "false",
            "modelTests": "false",
        },
    )

    extract_java_models_from_openapi_codegen(
        name = "{name}_model_jar".format(name = name),
        src = "{name}_codegen".format(name = name),
        model_package = model_namespace,
    )

    native.java_library(
        name = name,
        resource_jars = ["{name}_model_jar".format(name = name)],
    )