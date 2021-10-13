dotnet clean
dotnet restore .
dotnet build .
dotnet test --filter "FullyQualifiedName~UnitTest"