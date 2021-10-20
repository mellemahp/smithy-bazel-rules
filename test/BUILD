load("//smithy:smithy.bzl", "smithy_library", "smithy_openapi")

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
    srcs = [
        ":model_files",
        ":smithy_library_build_test",
    ],
    config = "smithy-build.json",
    projection = "model",
    service_name = "Weather",
)

filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)
