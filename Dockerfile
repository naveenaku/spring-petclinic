# -----------------------------
# Build Stage (Maven + JDK 25)
# -----------------------------
FROM maven:3.9.11-eclipse-temurin-25 AS build

WORKDIR /app

# copy mvnw & wrapper config if present (optional) and project files
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
COPY src ./src

# make mvnw executable (if using the wrapper)
RUN if [ -f mvnw ]; then chmod +x mvnw; fi

# Use the wrapper if present, otherwise use mvn from the image
# The shell chooses ./mvnw if it exists, else mvn
RUN if [ -f mvnw ]; then ./mvnw -B -DskipTests package; else mvn -B -DskipTests package; fi

# -----------------------------
# Runtime Stage (JRE 25)
# -----------------------------
FROM eclipse-temurin:25-jre AS runtime

WORKDIR /app

# copy the built jar from the build stage (matches spring-boot fat jar pattern)
COPY --from=build /app/target/*.jar app.jar

EXPOSE 4000

ENTRYPOINT ["java","-jar","/app/app.jar"]
