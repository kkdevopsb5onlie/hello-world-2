FROM tomcat:9.0

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file into Tomcat
COPY target/hello-web.war /usr/local/tomcat/webapps/ROOT.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
