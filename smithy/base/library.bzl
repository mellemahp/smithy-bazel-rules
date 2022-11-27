"""Bazel macro for generating smithy library jars

These library jar targets can be added as dependencies to other smithy build rules
and will be automatically discovered and merged into your smithy project by the smithy 
build cli

"""

load("//smithy:common.bzl", "generate_full_build_cmd")
load("//smithy/base:source_projection.bzl", "smithy_source_projection")

def smithy_library(name, srcs, config, root_dir=None, filters = []):
    smithy_source_projection(
        name = name + "source",
        srcs = srcs,
        config = config,
        root_dir = root_dir,
        filters = filters,
    )

    native.java_library(
        name = name,
        resources = [name + "source"]
    )
