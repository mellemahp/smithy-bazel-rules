<h2 align="center">Smithy Bazel Rules</h2>

<p align="center">
<!--Git Hub Action Badges-->
<a href="https://github.com/mellemahp/smithy-bazel-rules/actions">
<img 
alt="Actions Status" 
src="https://github.com/mellemahp/smithy-bazel-rules/actions/workflows/bazel.yml/badge.svg"
>
</a>
<a href="https://github.com/mellemahp/smithy-bazel-rules/blob/main/LICENSE">
<img 
alt="License" 
src="https://img.shields.io/github/license/mellemahp/smithy-bazel-rules"
>
</a>
<a href="https://github.com/mellemahp/smithy-bazel-rules/releases">
<img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/mellemahp/smithy-bazel-rules">
</a>
</p>

---

This repository contains rules for building Smithy models using the [Bazel](https://bazel.build/) build system. 

[Smithy](https://awslabs.github.io/smithy/) is an open source project by AWS that provides "a language for defining services and SDKs". Smithy uses a resource-based model and is intended to encourage evolvable design and codify interfaces. 

If you are using Smithy models in your project I encourage you to use (or fork and modify) the [Smithy Validators]() package to enforce your team's API standards programatically. 

I would like to the Smithy team for making such a great tool and the team at Meetup for the [Open Api Build Rules](https://github.com/meetup/rules_openapi) that served as inpiration for this project.

## Table of Contents 
- [Getting Started](#getting-started)  
    - [Setting Up Your Workspace](#setting-up-your-workspace)
    - [Building an Openapi Spec](#building-an-openapi-spec)  
    - [Smithy Libraries and Common models](#smithy-libraries-and-common-models)
    - [From Smithy Model to Generated Code](#from-smithy-model-to-generated-code)
- [Provided Build Rules](#provided-build-rules)
    - [smithy_openapi](#smithy_openapi)
    - [smithy_source](#smithy_source)
    - [smithy_library](#smithy_libary)

## Getting Started 
### Setting Up Your Workspace
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

This will pull down a release of the Smithy cli and make it available for use by the other build rules. You can now use the [smithy rules](#provided-build-rules) defined by this package within your workspace by adding the following to your `BUILD` file: 

```starlark
load("@smithy_rules//smithy:smithy.bzl", "<RULE_NAME>")
```

It is also possible to point your Smithy build rules to a location where you have downloaded the smithy cli jar (see build rule documentation below), but it is recommended to simply use the `smithy_cli_init()` rule in your `WORKSPACE` file to simplify development.

### Building an Openapi Spec
Most likely, you will want create an OpenApi spec with your smithy model. To do so, add the following to your BUILD file. We will assume you are using the `Weather` service definition from the [Smithy Quickstart Guide](https://awslabs.github.io/smithy/quickstart.html) for this example. 

```starlark
load("@smithy_rules//smithy:smithy.bzl", "smithy_openapi")

# package all of the model files into a single filegroup
filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)

# Build an openapi spec from your smithy model
smithy_openapi(
    name = "smithy_openapi_build_test",
    srcs = [":model_files"],
    config = "smithy-build.json",
    projection = "model",
    service_name = "Weather",
)
```

The output of the `smithy_openapi` rule is an openapi specification that can be depended upon by other rules such as a rule for openapi code generation.

Note that your `smithy-build.json` will need to include the openapi plugin
for this to work properly. See the example in the `test` folder of this repo for a template you can build off of. For the example above the `smithy-build.json` would look like: 

```json
{
    "version": "1.0",
    "projections": {
        "model": {
            "plugins": {
                "openapi": {
                    "service": "example.weather#Weather",
                    "protocol": "aws.protocols#restJson1",
                }
            }
        }
    }
}
```

To build the spec execute `bazel build //:smithy_open_api_build_test` within your workspace.

## Smithy Libraries and Common models
A smithy library build rule is also provided by this package. This library rule packages outputs of the smithy source projection as a Jar that can be depended on by other smithy packages. For example, you could use the Smithy library rule to package a common set of dependecies (such as common types definitions) for re-use by other Smithy models.

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
This will generate a build output that is the smithy model packaged into a JAR file. the smithy models are added to the `META-INF` folder of the JAR along with a manifest file that allows for model discovery by the smithy cli.

Because we should only be building the _source_ projection for smithy libraries we can have a dummy `smithy-build-dummy.json` for use in the library construction:
```json
{
    "version": "1.0"
}
```

Now, to use this library in another rule, simply add the library target as a denpendency of another smithy build rule (example provided in `test` folder):

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

The model files used in the Weather service definition can depend on the outputs of the smithy library using `use` statements like so: 

```
use example.pagelib#PageSize
use example.pagelib#Token
```

This allows for re-use of common models across multiple services.


### From Smithy Model to Generated Code
In most cases you will probably want more than just the OpenApi spec from your Model. In this section we walk through how to get usable auto-generated code from your smithy model using the [open api generator rules](https://github.com/OpenAPITools/openapi-generator-bazel) package.

Eventually, the Smithy project may decide to provide tools for code generation directly from a Smithy Model, but for the time being we can use the open source tools built around the OpenApi specification to generate code and documentation.

First we need to modify our `WORKSPACE` file to add 

```starlark
# Add this at the end of your existing WORKSPACE file
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "openapi_tools_generator_bazel",
    url = "https://github.com/OpenAPITools/openapi-generator-bazel/releases/download/0.1.5/openapi-tools-generator-bazel-0.1.5.tar.gz",
)

load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_tools_generator_bazel_repositories")

openapi_tools_generator_bazel_repositories()
```
This will pull in the OpenApi code generation CLI as an executable jar that other Bazel rules will use for generating code from an OpenApi spec.

Now, you can use the Open API gen rule to create a Java libary from your smithy model. The BUILD file below shows a full example of creating a java package from the smithy models in the `test` folder of this repo. 

```starlark
load("@smithy_rules//smithy:smithy.bzl", "smithy_library", "smithy_openapi")
load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_generator")

# Group all of the Smithy model files for the library of common models
filegroup(
    name = "library_files",
    srcs = [] + glob(["example/*"]),
)

# Create a jar containing the common smithy models that is discoverable by the 
# smithy cli tool 
smithy_library(
    name = "smithy_library_example",
    srcs = [":library_files"],
    config = "smithy-build-library.json",
    root_dir = "other",
)

# group all the model files to be used by the main 'Weather' service
filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)

# Create an OpenApi spec from the model for the `Weather` service
smithy_openapi(
    name = "smithy_openapi_spec",
    srcs = [":model_files"],
    deps = [":smithy_library_example"]
    config = "smithy-build.json",
    projection = "model",
    service_name = "Weather",
)

# Generate java libraries from the openapi spec
openapi_generator(
    name = "weather_codegen",
    model_package = "example.weather"
    generator = "java",
    spec = ":smithy_openapi_build_test",
)
```
Running `bazel build //:weather_codegen` will now generate a directory containing the code generated from your smithy model and openapi spec. In this case, we have placed the model files under the namespace `example.weather` which is likely where you would expect to import these from if you were importing these models into a Java program.

You can create a simple java rule below 

```starlark


```

A simple Macro is provided by this repository to generate a model package for java and python packages for you. They can be used as: 

```starlark 

# Python model library
load()

# Java model library
load()

```



## Example (Java): Using Smithy Build rules in a sample Bazel Project
We are now going to use our example weather service in an example 

## Example (Python): Using Smithy Build rules in a sampel Bazel Project
We are now going to use our example weather service in an example 



## Provided Build Rules

### `smithy_openapi`
#### **Rule Inputs**
#### **Example usage**

### `smithy_source`
#### **Rule Inputs**
#### **Example usage**

### `smithy_library`
#### **Rule Inputs**
#### **Example usage**