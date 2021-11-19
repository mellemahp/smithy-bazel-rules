workspace(name = "io_bazel_rules_smithy")

load("//smithy:smithy.bzl", "smithy_cli_init")

smithy_cli_init()

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "openapi_tools_generator_bazel",
    sha256 = "2daea1c94d6f101b4771ab3a82ef556ab1afb1669b135670b18000035ad8b60c",
    url = "https://github.com/mellemahp/openapi-generator-bazel/releases/download/0.1.5/openapi-tools-generator-bazel-0.1.5.tar.gz",
)

load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_tools_generator_bazel_repositories")

openapi_tools_generator_bazel_repositories()

# import libraries from maven
RULES_JVM_EXTERNAL_TAG = "2.8"

RULES_JVM_EXTERNAL_SHA = "79c9850690d7614ecdb72d68394f994fef7534b292c4867ce5e7dec0aa7bdfad"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "io.swagger.core.v3:swagger-annotations:2.1.11",
        "com.fasterxml.jackson.core:jackson-annotations:2.12.4",
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)
