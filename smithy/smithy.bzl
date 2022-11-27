"""Re-exports other build rules for convenience

"""

load("//smithy/base:library.bzl", _smithy_library = "smithy_library")
load("//smithy/base:source_projection.bzl", _smithy_source_projection = "smithy_source_projection")
load("//smithy/openapi:openapi.bzl", _smithy_openapi = "smithy_openapi")
load("//smithy/codegen:java.bzl", _smithy_java_models = "smithy_java_models")
load("//smithy/ast:ast.bzl", _smithy_ast = "smithy_ast")

# base projection/library rules
smithy_source_projection = _smithy_source_projection
smithy_library = _smithy_library

# openapi rules
smithy_openapi = _smithy_openapi

# codegen rules
smithy_java_models = _smithy_java_models

# ast rules
smithy_ast = _smithy_ast
