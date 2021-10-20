<h2 align="center">smithy-bazel-rules</h2>

<p align="center">
<!--Git Hub Action Badges-->
<a href="https://github.com/mellemahp/smithy-bazel-rules/actions"><img alt="Actions Status" src="https://github.com/mellemahp/smithy-bazel-rules/actions/workflows/bazel.yml/badge.svg"></a>
</p>

---

This repository contains rules for building Smithy models for use in bazel projects


### Getting Started 
In order to use the rules in your own project you will first need to pull down the repository from one of the release versions and initialize the 

In your workspace file add:
```starlark

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# update these values with the info of the release you want to use
SMITHY_RULES_TAG = "<Release_Tag i.e. 1.0.1>"
SMITHY_RULES_SHA = "<Release_SHA>"

http_archive(
    name = "smithy_rules",
    strip_prefix = "smithy-bazel-rules-%s" % SMITHY_RULES_TAG,
    url = "https://github.com/mellemahp/smithy-bazel-rules/archive/%s.zip" % SMITHY_RULES_TAG,
    sha256 = SMITHY_RULES_SHA
)

load("@smithy_rules//smithy:smithy.bzl", "smithy_cli_init")
smithy_cli_init()
```

This will pull down a release of the Smithy cli and make it available for use by the other build rules. 


#### Building an Openapi Spec
Most likely you will want to create an OpenApi spec with your smithy model. To do so, add the following to your BUILD file:

```starlark
load("@smithy_rules//smithy:smithy.bzl", "smithy_openapi")

# package all of the model files into a single filegroup
filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)

# Build an openapi spec from your smithy model
# NOTE: your smithy-build.json will need to include the openapi plugin
#       for this to work properly
smithy_openapi(
    name = "smithy_openapi_build_test",
    srcs = [":model_files"],
    config = "smithy-build.json",
    projection = "model",
    service_name = "Weather",
)
```
The output of the `smithy_openapi` rule is an openapi specification that can be depended upon by other rules such as a rule for openapi code generation.

#### Smithy Libraries and Common models
The Smithy library build rule is also provided by this package. This library rule packages smithy outputs as a Jar that can be depended on by other smithy packages. For example, you could use the Smithy library rule to package a common set of dependecies (such as common types definitions) for re-use by other Smithy models.

To create a smithy library add the Following to your `BUILD` file:
```starlark

load("@smithy_rules//smithy:smithy.bzl", "smithy_library")

filegroup(
    name = "library_files",
    srcs = [] + glob(["example/*"]),
)

smithy_library(
    name = "smithy_library_example",
    srcs = [":library_files"],
    config = "smithy-build-library.json",
    root_dir = "other",
)
```

This will generate a build output that is the smithy model packaged into a JAR file. Now, to use this library in another rule, simply add the library target as a denpendency of another smithy build rule:

```starlark 

filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)

smithy_openapi(
    name = "smithy_openapi_build_test",
    srcs = [":model_files"],
    deps = [":smithy_library_example"]
    config = "smithy-build.json",
    projection = "model",
    service_name = "Weather",
)
```
