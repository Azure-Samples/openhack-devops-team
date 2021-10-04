#Pull Base Image
FROM mcr.microsoft.com/dotnet/runtime:3.1 AS base
WORKDIR /app
#Pull SDK Image to Build Solution
FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src
COPY . .
# RUN dotnet restore -nowarn:msb3202,nu1503
RUN dotnet restore
WORKDIR /src/DeviceSim
RUN dotnet build -c Release -o /app
#Build .net solution
FROM build AS publish
RUN dotnet publish -c Release -o /app

FROM base AS final
WORKDIR /app
ENV SQL_USER="devopsohsa00" \
SQL_PASSWORD="devopsohdevpwd" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB" \
TRIP_FREQUENCY="180000" \
TEAM_NAME="devopsoh000test" \
USER_ROOT_URL="https://openhack${RGSUFFIX}userprofile.azurewebsites.net"\
POI_ROOT_URL="https://openhack${RGSUFFIX}poi.azurewebsites.net"\
TRIPS_ROOT_URL="https://openhack${RGSUFFIX}trips.azurewebsites.net" \
USE_API="true"
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "DeviceSim.dll"]
