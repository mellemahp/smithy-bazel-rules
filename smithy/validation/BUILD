exports_files(
    [
        "BUILD",
        "no-op-smithy-build.json",
        "validation.bzl",
    ],
)

filegroup(
    name = "validators",
    srcs = [] + glob(["validators/*.smithy"]),
    visibility = ["//visibility:public"],
)
