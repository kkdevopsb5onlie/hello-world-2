FROM eclipse-temurin:17-jre

WORKDIR /app

# copy jar from target folder
COPY target/*.jar app.jar

# run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
