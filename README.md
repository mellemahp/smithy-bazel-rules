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

If you are using Smithy models in your project I encourage you to use some of the Smithy validators defined in this project (see [Adding Builtin Validators]()) or create your own (see [Making A custom Validator]()). Smithy validators/linters help you to enforce API quality and consistency and catch common errors when you build your smithy model.


## Table of Contents 
- [Getting Started](#getting-started)  
    - [Setting Up Your Workspace](#setting-up-your-workspace)
    - [Building an Openapi Spec](#building-an-openapi-spec)  
    - [Smithy Libraries and Common models](#smithy-libraries-and-common-models)
    - [From Smithy Model to Generated Code](#from-smithy-model-to-generated-code)
- [Provided Build Rules](#provided-build-rules)
    - [smithy_openapi](#smithy_openapi)
    - [smithy_source](#smithy_source)
    - [smithy_library](#smithy_library)
- [Validators]()
    - [Adding Builtin Validators]()
    - [Making A custom Validator]()

## Getting Started 
### Setting Up Your Workspace
In order to use the rules in your own project you will first need to pull down the repository from one of the release versions and initialize both the smithy_cli and get the openapi generator rules package.

NOTE: the `openapi-generator-bazel` package currently points to a fork of the original repository ([forked repo](https://github.com/mellemahp/openapi-generator-bazel/)). This is because the origin repo currently has a error with correctly setting system properties. These properties are used in the Java Codegen rules. This example will be changed to point back to the origin project once this problem is corrected.

In your workspace file add:
```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

OPENAPI_GEN_VERSION = "0.1.5"
OPENAPI_GEN_SHA = "2daea1c94d6f101b4771ab3a82ef556ab1afb1669b135670b18000035ad8b60c"
http_archive(
    name = "openapi_tools_generator_bazel",
    sha256 = OPENAPI_GEN_SHA,
    url = "https://github.com/mellemahp/openapi-generator-bazel/releases/download/%s/openapi-tools-generator-bazel-%s.tar.gz" % (OPENAPI_GEN_VERSION, OPENAPI_GEN_VERSION),
)

load("@openapi_tools_generator_bazel//:defs.bzl", "openapi_tools_generator_bazel_repositories")

openapi_tools_generator_bazel_repositories()

SMITHY_RULES_TAG = "0.1.0"
SMITHY_RULES_SHA = "af438b7815c89156696c4097619f1b94a49090f8ea93808eef4f1e06f8187f8c"

http_archive(
    name = "smithy_rules",
    sha256 = SMITHY_RULES_SHA,
    url = "https://github.com/mellemahp/smithy-bazel-rules/releases/download/%s/release.tar.gz" % SMITHY_RULES_TAG,
)

load("@smithy_rules//smithy:deps.bzl", "smithy_cli_init")
smithy_cli_init()
```

This will pull down a release of the Smithy cli and make it available for use by the other build rules. You can now use the [smithy rules](#provided-build-rules) defined by this package within your workspace by adding the following to your `BUILD` file: 

```starlark
load("@smithy_rules//smithy:smithy.bzl", "<RULE_NAME>")
```

It is also possible to point your Smithy build rules to a location where you have downloaded the smithy cli jar (see build rule documentation below), but it is recommended to simply use the `smithy_cli_init()` rule in your `WORKSPACE` file to simplify development.

### Building an Openapi Spec
You may want to generate an OpenApi spec from your Smithy model. To do so, add the following to your BUILD file. We will assume you are using the `Weather` service definition from the [Smithy Quickstart Guide](https://awslabs.github.io/smithy/quickstart.html) for this example. 

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

The output of the `smithy_openapi` rule is an openapi specification json file that can be depended upon by other rules such as a rule for openapi code generation.

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

To build the spec, execute `bazel build //:smithy_open_api_build_test` within your workspace.

## Smithy Libraries and Common models
A smithy library build rule is also provided by this package. This library rule packages outputs of the smithy source projection as a Jar that can be depended on by other smithy packages. For example, you could use the Smithy library rule to package a common set of dependecies (such as common type definitions) for re-use by other Smithy models.

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

Because we should only be building the _source_ projection for smithy libraries we can have a dummy `smithy-build-library.json` for use in the library construction:

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
In most cases you will probably want more than just the OpenApi spec from your Model. In this section we walk through how to get usable auto-generated code from your smithy model using the [open api generator rules](https://github.com/OpenAPITools/openapi-generator-bazel) package and (where supported) using codegen tools from the Smithy team.

As the Smithy project supports additional languages for codegen we will try to add them here. For now only `Rust`, `GoLang`, and `TypeScript` are supported for codegen directly from the Smithy model. We can get a wider set of languages by using the OpenApi gen tool and a Smithy-generated openapi spec.

For example, you can use the Open API gen rule to create a Java libary from your smithy model. The BUILD file below shows a full example of creating a java package from the smithy models in the `test` folder of this repo. 

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

Additional macros are provided by this project to generate just the model files from a Smithy specification for a number of languages. 

## Java Model Codegen Macro
We are now going to use our example weather service to build just the Java model files for the service. These models are useful in both the backend and frontend services.

```
```

This will generate a new java library jar containing the models defined in the Smithy OpenAPI spec.

## TypeScript Codegen
[WIP]

## Validators
Smithy provides support for validators (or linters) that can be used to check the consistency and style of a service when Smithy builds the service model. This package provides support for a number of built in validators and an example custom validator is also proveded below.

### Adding Built in Validators
You can define a jar containing smithy validators as follows: 

```starlark
load("//smithy/validation:validation.bzl", "smithy_validator_library")

smithy_validator_library(
    name="validation_library", 
    filters = ["ValidationFileToSkip"]
)
```

You can then add this library jar as a dependency to another Smithy rule to add validation. For example, we could add our library above to an openApi Rule to add validation to that rule:

```starlark

smithy_openapi(
    name = "openapi_spec",
    srcs = [":model_files"],
    config = "smithy-build.json",
    projection = "model",
    service_name = "Weather",
    deps = [
        ":smithy_library",
        ":validation_library"
    ],
)

```

### Making A custom Validator
Let's say you want to add a validator that is not included in the built in validators, for example, you want to add a `ReservedWords` linter to prevent a project codename from being included in your public model. First, let's create a `my_validator.smithy` file in a folder named `extra_validations/`: 

```
$version: "1.0"

metadata validators = [{
    id: "MyReservedWords"
    name: "ReservedWords",
    configuration: {
        reserved: [
            {
                words: ["ReservedWord"],
                reason: "This is a reserved word. Dont use it.",
            },
        ]
    }
}]
```

You can now either just include the above file in the sources of a smithy rule or you can create a new smithy library containing this validation as: 

```starlark 
load("//smithy:smithy.bzl", "smithy_library")

smithy_library(
    name = "validation_lib",
    srcs = [":library_files"],
    config = "smithy-no-op-build.json",
    root_dir = "extra_validations",
)

filegroup(
    name = "library_files",
    srcs = [] + glob(["extra_validations/*"]),
)

```

We can then just include the library above as a dependency of our other smithy rules to enable it as a validation.


### Validation suppression
You can suppress a validator easily by adding a validation suppression trait to a resource. This should be used sparingly. For example, you could suppress the ReservedWords validator we made above by adding the following: 

```
@suppress(["MyReservedWords"])
string ReservedWordResource
```

## Provided Build Rules
The following are the build rules currently supported by this package

Additional build rules for TypeScript and GoLang codegen are planned

### `smithy_source_projection`
Runs the Smithy build task for the source projection of the Smithy model.
This is primarily used for creating Smithy libraries (seen `smithy_library` rule)

#### **Rule Inputs**
- **root_dir** [string] (default: model): root directory of smithy files 
- **deps** [label_list (*.jar)] (optional): dependency jars to add
- **srcs** [label_list (*.smithy, *.json)] (required): source files
- **config** [label (*.json)] (required): smithy build json file
- **logging** [string] (default = "INFO"): log level to use for smithy build cli
- **debug** [bool] (default = False): turns on debug logging for smithy cli
- **no_color** [bool] (default = False): turns off all colored output of smithy cli
- **force_color** [bool] (default = False): forces colored output of smithy cli
- **stacktrace** [bool] (default = False): get stack trace on smithy cli failure
- **filters** [string_list] (optional): files to filter out of jar construction
- **_jdk** [label] (optional): custom jdk to use
- **smithy_cli** [label] (optional): custom smithy_cli jar to use

#### **Example Usage**
```starlark
load("//smithy:smithy.bzl", "smithy_source_projection")

smithy_source_projection(
    name = "source",
    srcs = [":model_files"],
    config = "smithy-build.json",
    root_dir = "model",
    filters = ["FileToIgnore.smithy"],
)

filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)

```

### `smithy_library`
Creates a smithy library jar that can be depended on by other build rules

#### **Rule Inputs**
- **name** [string] (required): rule name
- **srcs** [label list (*.json, *.smithy)] (required): model file sources
- **config** [label (*.json)] (required): smithy build json to use
- **root_dir** [label] (required): root dir to use (ex. `models`)
- **filters** [string list] (default = []): files to filter out of library jar

#### **Example Usage**
```starlark
load("//smithy:smithy.bzl", "smithy_library")

smithy_library(
    name = "smithy_library",
    srcs = [":library_files"],
    config = "smithy-build.json",
    root_dir = "model",
)

filegroup(
    name = "library_files",
    srcs = [] + glob(["model/*"]),
)
```

### `smithy_openapi`
Generates an OpenApi spec from a smithy model projection. 

Note: Must have OpenApi plugin active for the selected projection

#### **Rule Inputs**
- **service_name** [string] (required): name of smithy service 
- **projection** [string] (required): name of projection to use for OpenAPI spec
- **deps** [label_list (*.jar)] (optional): dependency jars to add
- **srcs** [label_list (*.smithy, *.json)] (required): source files
- **config** [label (*.json)] (required): smithy build json file
- **logging** [string] (default = "INFO"): log level to use for smithy build cli
- **debug** [bool] (default = False): turns on debug logging for smithy cli
- **no_color** [bool] (default = False): turns off all colored output of smithy cli
- **force_color** [bool] (default = False): forces colored output of smithy cli
- **stacktrace** [bool] (default = False): get stack trace on smithy cli failure
- **filters** [string_list] (optional): files to filter out of jar construction
- **_jdk** [label] (optional): custom jdk to use
- **smithy_cli** [label] (optional): custom smithy_cli jar to use

#### **Example Usage**
```starlark
load("//smithy:smithy.bzl", "smithy_openapi")

smithy_openapi(
    name = "openapi_spec",
    srcs = [":model_files"],
    config = "smithy-build.json",
    projection = "model",
    service_name = "Weather",
    deps = [":smithy_library"],
)

filegroup(
    name = "model_files",
    srcs = [] + glob(["model/**"]),
)
```

### `smithy_java_models`
Generates java code for just the API models as a java library

#### **Rule Inputs**
- **name** [string] (required): name of build 
- **srcs** [label] (required): smithy model file sources
- **config** [label] (required): Smithy build json to use for build
- **projection** [string] (required): Projection to use for generation models
- **service_name** [string] (required): Name of service as defined in smithy model
- **model_namespace** [string] (required): Java namespace to put model files 
- **deps** [label list] (optional): dependencies
- **gen_library** [string] (default = "feign"): Framework to target for code gen

#### **Example Usage**
```starlark
load("//smithy:smithy.bzl", "smithy_java_models")

smithy_java_models(
    name = "model_gen_java",
    srcs = [":model_files"],
    config = "smithy-build.json",
    model_namespace = "example.weather",
    projection = "model",
    service_name = "Weather",
    deps = [":smithy_library"],
)
```