# Etape 1 : compilation
FROM eclipse-temurin:25-jdk AS builder

WORKDIR /app
COPY . .
RUN ./gradlew bootJar --no-daemon

# Etape 2 : creation d'un JRE minimal avec jlink
FROM eclipse-temurin:25-jdk AS jlink-builder

RUN $JAVA_HOME/bin/jlink \
    --add-modules java.base,java.naming,java.logging,java.management,java.security.jgss,java.desktop,java.xml,java.instrument \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /jre-minimal

# Etape 3 : image finale ultra-legere
FROM debian:bookworm-slim

COPY --from=jlink-builder /jre-minimal /jre-minimal
COPY --from=builder /app/build/libs/*.jar /app/app.jar

ENV PATH="/jre-minimal/bin:$PATH"
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]