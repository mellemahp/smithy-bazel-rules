load("//smithy:smithy.bzl", "smithy_library", "smithy_ast")

smithy_library(
    name = "smithy_library_build_test",
    srcs = [":library_files"],
    config = "smithy-build-no-op.json",
    root_dir = "other",
)

filegroup(
    name = "library_files",
    srcs = [] + glob(["other/**"]),
)

smithy_library(
    name = "validation_lib",
    srcs = ["//smithy/validation:validators"],
    config = "smithy-build-no-op.json",
    filters = ["ShouldHaveUsedTimestamp"],
    root_dir = "validators",
)

filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)

smithy_ast(
    name = "smithy_ast_build_test",
    srcs = [":model_files"],
    config = "smithy-build.json",
    projection = "model",
    deps = [
        ":validation_lib",
        ":smithy_library_build_test",
    ],
)