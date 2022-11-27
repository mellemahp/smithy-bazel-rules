load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

package(default_visibility = ["//visibility:public"])

pkg_tar(
    name = "release",
    srcs = [
        "BUILD",
        "LICENSE",
        "//smithy:BUILD",
        "//smithy:common.bzl",
        "//smithy:deps.bzl",
        "//smithy:smithy.bzl",
        # Openapi build
        "//smithy/openapi:BUILD",
        "//smithy/openapi:openapi.bzl",
        # Library and source projections
        "//smithy/base:BUILD",
        "//smithy/base:library.bzl",
        "//smithy/base:source_projection.bzl",
        # Codegen
        "//smithy/codegen:BUILD",
        "//smithy/codegen:java.bzl",
        "//smithy/codegen:typescript.bzl",
        # Validation
        "//smithy/validation:BUILD",
        # Validators
        "//smithy/validation:validators",
        # AST Extraction
        "//smithy/ast:BUILD",
        "//smithy/ast:ast.bzl"
    ],
    extension = "tar.gz",
    strip_prefix = "./io_bazel_rules_smithy",
)
