# POI Service

## Overview

POI (Trip Points of Interest) - CRUD API written in .NET Core 3.1 for Points of Interest on trips.

## Build & Test

### Restore dependencies

```shell
dotnet restore
```

> **NOTE:** Starting with .NET Core 2.0 SDK, you don't have to run [`dotnet restore`](https://docs.microsoft.com/dotnet/core/tools/dotnet-restore) because it's run implicitly by all commands that require a restore to occur, such as `dotnet new`, `dotnet build` and `dotnet run`.
It's still a valid command in certain scenarios where doing an explicit restore makes sense, such as [continuous integration builds in Azure DevOps Services](https://docs.microsoft.com/azure/devops/build-release/apps/aspnet/build-aspnet-core) or in build systems that need to explicitly control the time at which the restore occurs.

### Build the Application

```shell
dotnet build
```

### Testing

You can run the test in Visual Studio/VSCode or with the command line.

To use the command line just type:

```shell
dotnet test --logger "trx;LogFileName=TestResults.trx" --results-directory ./TestResults
```

This will run both the **Unit Tests** and the **Integration Tests**.

#### Unit Tests

To run only the **Unit Tests** use filters:

```shell
dotnet test --filter "FullyQualifiedName~UnitTest" --logger "trx;LogFileName=UnitTestResults.trx" --results-directory ./TestResults
```

#### Integration Tests

To run only the **Integration Tests** use filters:

```shell
dotnet test --filter "FullyQualifiedName~IntegrationTests" --logger "trx;LogFileName=IntegrationTestResults.trx" --results-directory ./TestResults
```

> **NOTE:** **Integration Tests** require the Database to be available

## References

- [Web API](https://docs.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-3.1)
- [Unit Testing](https://docs.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-dotnet-test)
- [Integration Testing](https://docs.microsoft.com/en-us/aspnet/core/test/integration-tests?view=aspnetcore-3.1)
- [Unit testing using dotnet test](https://github.com/dotnet/samples/tree/main/core/getting-started/unit-testing-using-dotnet-test)
- [Run selective unit tests](https://docs.microsoft.com/en-us/dotnet/core/testing/selective-unit-tests?pivots=xunit)
- [Logging in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/logging/?view=aspnetcore-3.1)
