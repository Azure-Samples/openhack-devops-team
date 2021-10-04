FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS build
WORKDIR /src
COPY . .
RUN dotnet publish "web/TripViewer.csproj" -c Release -o /publish

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine
ENV USER_ROOT_URL="https://openhackuserprofile.azurewebsites.net"
ENV POI_ROOT_URL="https://openhackpoi.azurewebsites.net"
ENV TRIPS_ROOT_URL="https://openhacktrips.azurewebsites.net"
ENV USER_JAVA_ROOT_URL="https://openhackuserjava.azurewebsites.net"
ENV BING_MAPS_KEY="changeme"

WORKDIR /app
COPY --from=build /publish .
ENTRYPOINT ["dotnet", "TripViewer.dll"]
