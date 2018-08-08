FROM openjdk:10-jre-slim

EXPOSE 8080

ENV SQL_USER="davete02ted2sa"
ENV SQL_PASSWORD="5N6nk3La2pwd"
ENV SQL_SERVER="jdbc:sqlserver://davete02ted2sql.database.windows.net;databaseName=mydrivingDB;trustServerCertificate=true;selectMethod=cursor"
ENV SQL_DBNAME="mydrivingDB"

# Add the application's jar to the container
ADD target/swagger-spring-1.0.0.jar userprofile-java.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/userprofile-java.jar"]