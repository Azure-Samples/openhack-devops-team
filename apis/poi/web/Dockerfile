FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build-env
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out
COPY ./appsettings.*.json /app/out/
COPY ./appsettings.json /app/out/

# build runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
WORKDIR /app

# docker build argument
#    This can be specified during the docker build step by adding " --build-arg build_version=<value>"
#    App version can be accessed via the uri path /api/version/poi
#    https://vsupalov.com/docker-build-pass-environment-variables/
ARG build_version="poi default"

ENV SQL_USER="YourUserName" \
SQL_PASSWORD="changeme" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB" \
WEB_PORT="8080" \
WEB_SERVER_BASE_URI="http://0.0.0.0" \
ASPNETCORE_ENVIRONMENT="Production" \
APP_VERSION=$build_version 

COPY --from=build-env /app/out .

EXPOSE 8080

ENTRYPOINT ["dotnet", "poi.dll"]

