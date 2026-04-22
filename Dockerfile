# Etape 1 : compilation
FROM eclipse-temurin:25-jdk AS builder

WORKDIR /app
COPY . .
RUN ./gradlew bootJar --no-daemon

# Etape 2 : execution avec image legere
FROM eclipse-temurin:25-jre AS runner

WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]