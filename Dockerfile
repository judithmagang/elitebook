FROM tomcat:9.0.37-jdk8
ADD ./target/elitebook-1.0.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD "catalina.sh"  "run"


