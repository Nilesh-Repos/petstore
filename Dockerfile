#
#    Copyright 2010-2023 the original author or authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       https://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

#FROM openjdk:11-jdk-slim
#COPY . /usr/src/myapp
#WORKDIR /usr/src/myapp
#RUN chmod +x ./mvnw
#RUN ./mvnw clean package -Dlicense.skip=true
#CMD ./mvnw cargo:run -P tomcat90


# Stage 1: Build the WAR file using Maven Wrapper
FROM openjdk:11-jdk-slim AS build

# Install Maven dependencies
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Copy source code
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

# Make mvnw executable and build WAR
RUN chmod +x ./mvnw && ./mvnw clean package -Dlicense.skip=true

# Stage 2: Create final image with Tomcat
FROM openjdk:11-jdk-slim

# Install wget and Tomcat
RUN apt-get update && apt-get install -y wget && \
    wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.96/bin/apache-tomcat-9.0.96.tar.gz && \
    tar xzf apache-tomcat-9.0.96.tar.gz && \
    mv apache-tomcat-9.0.96 /opt/tomcat && \
    rm apache-tomcat-9.0.96.tar.gz && \
    rm -rf /var/lib/apt/lists/*

# Copy WAR file from build stage to Tomcat
COPY --from=build /usr/src/myapp/target/*.war /opt/tomcat/webapps/

# Expose Tomcat port
EXPOSE 8080

# Run Tomcat in foreground
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
