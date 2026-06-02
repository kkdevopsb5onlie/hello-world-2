FROM eclipse-temurin:17-jre

WORKDIR /app

COPY . .

CMD ["java", "-version"]
