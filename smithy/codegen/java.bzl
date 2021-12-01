"""Bazel rules for generating Java models from smithy model

"""

load("//smithy/openapi:openapi.bzl", "smithy_openapi")
load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_generator")

def extract_model_sourcejar(ctx, java_runtime):
    jar_path = "%s/bin/jar" % java_runtime.java_home

    srcjar = ctx.actions.declare_file("%s-model-gensrc.jar" % ctx.label.name)

    cmd = "%s cf" % jar_path

    # add output jar file path
    cmd += " %s" % srcjar.path

    # select the path of the code gen output
    cmd += " -C %s/src/main/java/" % ctx.file.src.path

    # add namespace of file
    cmd += " %s" % "/".join(ctx.attr.model_package.split("."))

    ctx.actions.run_shell(
        inputs = ctx.files._jdk + [ctx.file.src],
        outputs = [srcjar],
        command = cmd,
    )

    return srcjar

def _impl_extract_java_models_from_openapi_codegen(ctx):
    java_toolchain = ctx.attr._java_toolchain[java_common.JavaToolchainInfo]
    java_runtime = ctx.attr._jdk[java_common.JavaRuntimeInfo]

    srcjar = extract_model_sourcejar(ctx, java_runtime)
    deps_java_info = java_common.merge([dep[JavaInfo] for dep in ctx.attr.deps])

    java_info = java_common.compile(
        ctx,
        java_toolchain = java_toolchain,
        output = ctx.outputs.model_jar,
        output_source_jar = ctx.outputs.model_srcjar,
        source_jars = [srcjar],
        deps = [java_common.make_non_strict(deps_java_info)],
    )

    return [java_info]

extract_java_models_from_openapi_codegen = rule(
    attrs = {
        # output of openapi code gen
        "src": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        # deps for generated library
        "deps": attr.label_list(
            mandatory = True,
            allow_empty = False,
            providers = [JavaInfo],
        ),
        # namespace of model package
        "model_package": attr.string(mandatory = True),
        "_jdk": attr.label(
            default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
            providers = [java_common.JavaRuntimeInfo],
        ),
        "_java_toolchain": attr.label(
            default = "@bazel_tools//tools/jdk:current_java_toolchain",
        ),
    },
    outputs = {
        "model_jar": "lib%{name}-models.jar",
        "model_srcjar": "lib%{name}-models-src.jar",
    },
    fragments = ["java"],
    provides = [JavaInfo],
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
        name = "openapi_gen_{name}".format(name = name),
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
        name = name,
        deps = [
            "@maven//:io_swagger_swagger_annotations",
            "@maven//:com_fasterxml_jackson_core_jackson_annotations",
            "@maven//:javax_annotation_javax_annotation_api",
            "@maven//:org_openapitools_jackson_databind_nullable",
            "@maven//:com_google_code_findbugs_jsr305",
        ],
        src = "openapi_gen_{name}".format(name = name),
        model_package = model_namespace,
    )
