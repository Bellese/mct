FROM maven:3.9.6-eclipse-temurin-17 AS build

COPY mvnw .
COPY pom.xml .
COPY src src

RUN mvn clean package -DskipTests

ENTRYPOINT ["mvn", "spring-boot:run"]
