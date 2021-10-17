#!/bin/bash

# clean the output of the previous build
dotnet clean

# restore dependencies
dotnet restore

# build the project
dotnet build --no-restore

# run selective test - unit tests
dotnet test --no-build --filter "FullyQualifiedName~UnitTest"

# run selective test - integrations tests
dotnet test --no-build --filter "FullyQualifiedName~IntegrationTests"

# run all tests
dotnet test --no-build