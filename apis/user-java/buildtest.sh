#!/bin/bash

# https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html

# clean the output of the previous build
mvn clean

# run unit tests
mvn test

# create distributable package
mvn package

# run integration tests
mvn verify