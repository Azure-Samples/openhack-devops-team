cd tools
dotnet restore 
cd .. 
cd tests/UnitTests/ 
dotnet restore
dotnet build
cd ../..
cd tools
dotnet minicover instrument --workdir ../ --assemblies tests/UnitTests/bin/Debug/netcoreapp2.1/*.dll --sources web/**/*.cs --sources web/*.cs
dotnet minicover reset
cd ..
for project in tests/UnitTests/*.csproj; do dotnet test --no-build $project; done
cd tools
dotnet minicover uninstrument --workdir ../
dotnet minicover htmlreport --workdir ../ --threshold 90
dotnet minicover report --workdir ../ --threshold 90

