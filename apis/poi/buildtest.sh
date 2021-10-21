#!/bin/bash

# clean the output of the previous build
dotnet clean

# restore dependencies
dotnet restore

# build the project
dotnet build --no-restore

# run selective test - unit tests
dotnet test --no-build --filter "FullyQualifiedName~UnitTest" --logger "trx;LogFileName=UnitTestResults.trx" --results-directory ./TestResults

# run selective test - integrations tests
dotnet test --no-build --filter "FullyQualifiedName~IntegrationTests" --logger "trx;LogFileName=IntegrationTestResults.trx" --results-directory ./TestResults 

# run all tests
dotnet test --no-build