# Using 'ubuntu' as the base image here
FROM ubuntu
ARG ACSSDK
ARG JAVADEB


RUN echo ${ACSSDK}
RUN echo ${JAVADEB}

# setting the working directory
WORKDIR /opt/aem

# Copy the license file
#COPY license.properties .

# Copy Quickstart jar file
COPY ${ACSSDK} cq-quickstart.jar


COPY ${JAVADEB} /tmp/jdk-11.x.xx_linux-x64_bin.deb

# Install Java
# https://stackoverflow.com/a/54925400
RUN apt-get update
RUN apt-get install -y nodejs maven
RUN dpkg -i /tmp/jdk-11.x.xx_linux-x64_bin.deb
RUN update-alternatives --install /usr/bin/java java "`ls /usr/lib/jvm/* | grep oracle | sort | tr -d ':' | head -n1`"/bin/java 11111

RUN node -v
RUN mvn -v

#https://experienceleague.adobe.com/en/docs/experience-manager-65/content/implementing/deploying/deploying/custom-standalone-install#further-options-available-from-the-quickstart-file
# https://stackoverflow.com/questions/43655291/dynamically-set-java-home-of-docker-container
RUN export JAVA_HOME="`ls /usr/lib/jvm/* | grep oracle | sort | tr -d ':' | head -n1`" && \
    echo $JAVA_HOME && \
    java --version && \
    java -jar cq-quickstart.jar -unpack

RUN mkdir crx-quickstart/install

COPY install crx-quickstart/install

COPY ep.sh /ep.sh
RUN chmod +x /ep.sh

#RUN export COMMERCE_ENDPOINT=https

# docker run --rm -ti --memory=24g aem6.5.0java
#COPY *.java /src/
#RUN mkdir /app \
#    && ls /src \
#    && /usr/lib/jvm/jdk-11/bin/javac /src/PrintXmxXms.java -d /app
#CMD ["sh", "-c", \
#     "java -version \
#      && java -cp /app PrintXmxXms"]
