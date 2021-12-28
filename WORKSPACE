workspace(name = "io_bazel_rules_smithy")

# Setup and download Smith build Cli executable jar
load("//smithy:deps.bzl", "smithy_cli_init")

smithy_cli_init()

# Download and set up rules for working with the Openapi codegen tool
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "openapi_tools_generator_bazel",
    sha256 = "6e3019e4f63a5cb478d84e6e3852fa1f573365c5a65a513b25e8ff9def4d54e7",
    url = "https://github.com/mellemahp/openapi-generator-bazel/releases/download/0.1.6/openapi-tools-generator-bazel-0.1.6.tar.gz",
)

load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_tools_generator_bazel_repositories")

openapi_tools_generator_bazel_repositories()

################
### MAVEN
################
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
        "javax.annotation:javax.annotation-api:1.3.2",
        "com.fasterxml.jackson.core:jackson-annotations:2.12.4",
        "io.swagger:swagger-annotations:1.6.3",
        "org.openapitools:jackson-databind-nullable:0.2.2",
        "com.google.code.findbugs:jsr305:3.0.2",
    ],
    repositories = [
        "https://repo1.maven.org/maven2",
    ],
)
