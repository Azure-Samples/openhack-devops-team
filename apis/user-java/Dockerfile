FROM openjdk:8-jdk-alpine

EXPOSE 8080

# Add a volume pointing to /tmp
VOLUME /tmp

# The application's jar file
ARG JAR_FILE=target/swagger-spring-1.0.0.jar

# Add the application's jar to the container
ADD ${JAR_FILE} userprofile-java.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/userprofile-java.jar"]