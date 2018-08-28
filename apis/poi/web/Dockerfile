FROM microsoft/dotnet:2.1-sdk AS build-env
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
FROM microsoft/dotnet:2.1-aspnetcore-runtime
WORKDIR /app

ENV SQL_USER="__SQLUSER__" \
SQL_PASSWORD="__SQLPASS__" \
SQL_SERVER="__SQLSERVER__.database.windows.net" \
SQL_DBNAME="mydrivingDB" \
WEB_PORT="8080" \
WEB_SERVER_BASE_URI="http://0.0.0.0" \
ASPNETCORE_ENVIRONMENT="Production" \
WHOS_AWESOME="you" \
WHOS_ALSO_AWESOME="Damien"

COPY --from=build-env /app/out .

ENTRYPOINT ["dotnet", "poi.dll"]

