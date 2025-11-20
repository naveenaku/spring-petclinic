# -----------------------------
# Build Stage
# -----------------------------
FROM maven:3.9.4-eclipse-temurin-17 AS build

WORKDIR /app

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
COPY src ./src

RUN chmod +x mvnw
RUN ./mvnw -B -DskipTests package

# -----------------------------
# Runtime Stage
# -----------------------------
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 4000 

ENTRYPOINT ["java", "-jar", "/app/app.jar"]

