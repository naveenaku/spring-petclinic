# -----------------------------
# Build Stage (Java 25)
# -----------------------------
FROM maven:3.9.11-eclipse-temurin-25 AS build

WORKDIR /app
COPY . .
RUN mvn -B -DskipTests clean package

# -----------------------------
# Runtime Stage (Java 25)
# -----------------------------
FROM eclipse-temurin:25-jre

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 4000
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
