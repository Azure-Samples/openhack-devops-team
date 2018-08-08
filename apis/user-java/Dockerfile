FROM openjdk:10-jre-slim

EXPOSE 8080

ENV SQL_USER="YourUserName" \
SQL_PASSWORD="changeme" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB"

# Add the application's jar to the container
ADD target/swagger-spring-1.0.0.jar userprofile-java.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/userprofile-java.jar"]