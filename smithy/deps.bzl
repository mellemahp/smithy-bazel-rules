"""Initialization rules for using Smithy Build rules

This file contains a rule to pull the the CLI jar file from a repository.
The intialization rule should be run in the WORKSPACE file to set up your 
workspace for using other smithy rules

Supported providers: 
- Currently only @mellemahp's smithy-cli-executabel repo is supported. This reoo
creates a convenient executable jar with a number of common smithy dependencies included
See the repo here: https://github.com/mellemahp/smithy-cli-executable

"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_jar")

_SUPPORTED_PROVIDERS = {
    "mellemahp": {
        "name": "smithy_cli",
        "versions": {
            "1.14.0": {
                "artifact": "smithy-cli.jar",
                "url": "https://github.com/mellemahp/smithy-cli-executable/releases/download/1.14.0/smithy_cli.jar",
                "sha": "6fa4a856517a23ed4ad57ee3b80fdd92a675acc37597a2364072d785a9f65849",
            },
        },
    },
}

def smithy_cli_init(
        smithy_cli_version = "1.14.0",
        smithy_cli_provider = "mellemahp",
        prefix = "io_bazel_rules_smithy"):
    http_jar(
        name = prefix + "_" + _SUPPORTED_PROVIDERS[smithy_cli_provider]["name"],
        sha256 = _SUPPORTED_PROVIDERS[smithy_cli_provider]["versions"][smithy_cli_version]["sha"],
        url = _SUPPORTED_PROVIDERS[smithy_cli_provider]["versions"][smithy_cli_version]["url"],
    )

    native.bind(
        name = prefix + "/dependency/smithy-cli",
        actual = "@" + prefix + "_" + _SUPPORTED_PROVIDERS[smithy_cli_provider]["name"] + "//jar",
    )
