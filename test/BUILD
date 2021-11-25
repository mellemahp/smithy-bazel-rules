load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_generator")
load("//smithy:smithy.bzl", "smithy_java_models", "smithy_library", "smithy_openapi")

smithy_library(
    name = "smithy_library_build_test",
    srcs = [":library_files"],
    config = "smithy-build-no-op.json",
    root_dir = "other",
)

filegroup(
    name = "library_files",
    srcs = [] + glob(["other/*"]),
)

smithy_openapi(
    name = "smithy_openapi_build_test",
    srcs = [":model_files"],
    config = "smithy-build.json",
    projection = "model",
    service_name = "Weather",
    deps = [":smithy_library_build_test"],
)

filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)

openapi_generator(
    name = "weather_codegen",
    additional_properties = {
        "library": "feign",
    },
    generator = "java",
    model_package = "example.weather",
    spec = ":smithy_openapi_build_test",
    system_properties = {
        "models": "",
        "modelDocs": "false",
        "apiTests": "false",
        "modelTests": "false",
    },
)

smithy_java_models(
    name = "test_model_gen",
    srcs = [":model_files"],
    config = "smithy-build.json",
    model_namespace = "example.weather",
    projection = "model",
    service_name = "Weather",
    deps = [":smithy_library_build_test"],
)
