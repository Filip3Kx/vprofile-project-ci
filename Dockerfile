FROM tomcat:9-jre11
WORKDIR /usr/local/tomcat
RUN rm -rf /usr/local/tomcat/webapps/*
COPY ./target/vprofile-v2.war ./webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
VOLUME /usr/local/tomcat/webapps
