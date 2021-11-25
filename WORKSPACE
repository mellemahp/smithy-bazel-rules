workspace(name = "io_bazel_rules_smithy")

# Setup and download Smith build Cli executable jar
load("//smithy:deps.bzl", "smithy_cli_init")

smithy_cli_init()

# Download and set up rules for working with the Openapi codegen tool
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "openapi_tools_generator_bazel",
    sha256 = "2daea1c94d6f101b4771ab3a82ef556ab1afb1669b135670b18000035ad8b60c",
    url = "https://github.com/mellemahp/openapi-generator-bazel/releases/download/0.1.5/openapi-tools-generator-bazel-0.1.5.tar.gz",
)

load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_tools_generator_bazel_repositories")

openapi_tools_generator_bazel_repositories()
