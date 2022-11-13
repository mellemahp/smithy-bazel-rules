"""
This module contains all of the dependencies installed via rules_jvm_external
"""

#####################
# JAVA DEPENDENCIES #
#####################
MAVEN_REPOS = [
    "https://repo1.maven.org/maven2",
]

JACKSON_VERSION = "2.14.0-rc2"

JAVA_DEPENDENCIES = [
    "javax.annotation:javax.annotation-api:1.3.2",
    "com.fasterxml.jackson.core:jackson-annotations:%s" % JACKSON_VERSION,
    "io.swagger:swagger-annotations:1.6.3",
    "org.openapitools:jackson-databind-nullable:0.2.4",
    "com.google.code.findbugs:jsr305:3.0.2",
]