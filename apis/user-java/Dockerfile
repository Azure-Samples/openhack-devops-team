# First stage to build the application
FROM maven:3.5.4-jdk-11-slim AS build-env
ADD ./pom.xml pom.xml
ADD ./src src/
RUN mvn clean package

# build runtime image
FROM openjdk:11-jre-slim

EXPOSE 8080

# docker build argument
#    This can be specified during the docker build step by adding " --build-arg build_version=<value>"
#    App version can be accessed via the uri path /api/version/user-java
#    https://vsupalov.com/docker-build-pass-environment-variables/
ARG build_version="user-java default"

ENV SQL_USER="YourUserName" \
SQL_PASSWORD="changeme" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB" \
APP_VERSION=$build_version 

# Add the application's jar to the container
COPY --from=build-env target/swagger-spring-1.0.0.jar user-java.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/user-java.jar"]