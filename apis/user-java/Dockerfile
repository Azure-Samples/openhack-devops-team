# First stage to build the application
FROM maven:3.5.4-jdk-10-slim AS build-env
ADD ./pom.xml pom.xml
ADD ./src src/
RUN mvn clean package

# build runtime image
FROM openjdk:10-jre-slim

EXPOSE 8080

ENV SQL_USER="__SQLSERVERUSERNAME__" \
SQL_PASSWORD="__SQLSERVERPASSWORD__" \
SQL_SERVER="__SQLSERVERNAME__" \
SQL_DBNAME="__SQLDBNAME__"

# Add the application's jar to the container
COPY --from=build-env target/swagger-spring-1.0.0.jar user-java.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/user-java.jar"]