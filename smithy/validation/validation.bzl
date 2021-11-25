"""Tools to quickly generate a smithy library jar containing validators

This macro allows users to filter out validation files starting with a given pattern,
making in quick to create a standard library for validating smithy models.

"""

load("//smithy:smithy.bzl", "smithy_library")

FILTER_EXTENSION = ".smithy"

def smithy_validator_library(name, filters = []):
    # get built in validators
    validators = native.glob(["validators/*.smithy"])

    # check that filters have correct extension
    updated_filters = []
    for filter in filters:
        if not filter.endswith(FILTER_EXTENSION):
            filter += FILTER_EXTENSION
        updated_filters.append(filter)

    smithy_library(
        name = name,
        srcs = validators,
        config = "no-op-smithy-build.json",
        root_dir = "validators",
        filters = updated_filters,
    )
