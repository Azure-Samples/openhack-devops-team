FROM microsoft/dotnet:2.1-sdk AS build-env
WORKDIR /app

# copy csproj and restore as distinct layers
COPY . .

# copy everything else and build
RUN dotnet publish -c Release -o app/out web/poi.csproj
COPY ./web/appsettings.*.json /app/out/
COPY ./web/appsettings.json /app/out/

# run unit tests
COPY tests tests/
RUN dotnet test tests/IntegrationTests
RUN dotnet test tests/UnitTests

# build runtime image
FROM microsoft/dotnet:2.1-aspnetcore-runtime
WORKDIR /app

ENV SQL_USER="YourUserName" \
SQL_PASSWORD="changeme" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB" \
WEB_PORT="8080" \
WEB_SERVER_BASE_URI="http://0.0.0.0" \
ASPNETCORE_ENVIRONMENT="Production"

COPY --from=build-env /app/out .

ENTRYPOINT ["dotnet", "poi.dll"]

