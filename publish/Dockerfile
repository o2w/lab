# Use the previously created aem6.X.0
ARG AEM=''
FROM ${AEM}

# Expose AEM Publisher in port 4502
EXPOSE 4503

RUN export JAVA_HOME="`ls /usr/lib/jvm/* | grep oracle | sort | tr -d ':' | head -n1`" && \
    echo $JAVA_HOME && \
    java -version

RUN test -f "./cq-quickstart.jar" && mv ./cq-quickstart.jar ./aem-publish-p4503.jar

# Make the container start always in Publisher mode with Port 4503
#https://experienceleague.adobe.com/docs/experience-manager-learn/cloud-service/local-development-environment-set-up/aem-runtime.html?lang=en#set-up-local-aem-publish-service
ENTRYPOINT ["java", "-jar", "aem-publish-p4503.jar" ]
