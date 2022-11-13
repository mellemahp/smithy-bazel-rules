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
RULES_JVM_EXTERNAL_TAG = "4.4.2"
RULES_JVM_EXTERNAL_SHA = "735602f50813eb2ea93ca3f5e43b1959bd80b213b836a07a62a29d757670b77b"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)
load("@rules_jvm_external//:repositories.bzl", "rules_jvm_external_deps")
rules_jvm_external_deps()

load("@rules_jvm_external//:setup.bzl", "rules_jvm_external_setup")
rules_jvm_external_setup()

load("@rules_jvm_external//:defs.bzl", "maven_install")


#####################
# Java Dependencies #
#####################
load("//:dependencies.bzl", "JAVA_DEPENDENCIES", "MAVEN_REPOS")
maven_install(
    name = "maven",
    artifacts = JAVA_DEPENDENCIES,
    repositories = MAVEN_REPOS,
)