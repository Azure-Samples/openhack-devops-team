#!/bin/bash

# clean the output of the previous build
go clean

# get & install dependencies
go get

# build the project
go build

# run unit tests
go test -v ./tripsgo -run Unit -coverprofile=unittest_coverage.out -covermode=count

# run integration tests
go test -v ./tripsgo

# setup gotestsum
chmod +x install_gotestsum.sh
./install_gotestsum.sh

# run unit tests using gotestsum and generate junit report
./gotestsum --format standard-verbose --junitfile unittest_results.xml -- ./tripsgo -run Unit -coverprofile=unittest_coverage.out -covermode=count

# run integration test susing gotestsum and generate junit report
./gotestsum --format standard-verbose --junitfile integrationtest_results.xml -- ./tripsgo