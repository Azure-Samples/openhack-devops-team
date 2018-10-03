FROM gokgokalp/sonar-scanner-dotnetcore-msbuild:latest AS build-env

ARG PROJECT_KEY
ARG PROJECT_NAME
ARG PROJECT_VERSION
ARG SONAR_HOST
ARG SONAR_LOGIN_KEY
ARG SONAR_ORG

WORKDIR /app

# Sonar scanner start
RUN mono /opt/sonar-scanner-msbuild/SonarQube.Scanner.MSBuild.exe begin /d:sonar.host.url="$SONAR_HOST" /d:sonar.login="$SONAR_LOGIN_KEY" /k:"$PROJECT_KEY" /n:"$PROJECT_NAME" /v:"$PROJECT_VERSION" /d:sonar.oraganization="$SONAR_ORG"

RUN dotnet restore
RUN dotnet build
RUN dotnet test

RUN mono /opt/sonar-scanner-msbuild/SonarQube.Scanner.MSBuild.exe end /d:sonar.login="$SONAR_LOGIN_KEY"
# Sonar scanner end