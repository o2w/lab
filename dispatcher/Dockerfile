#https://experienceleague.adobe.com/en/docs/experience-manager-learn/cloud-service/local-development-environment-set-up/dispatcher-tools#run-dispatcher-locally

# Using the apache base Image
FROM httpd:2.4

# Setting the current working directory
WORKDIR /usr/src/app

# Get the dispacher tar file and keepit inside 'dispacher' folder
# https://experienceleague.adobe.com/docs/experience-manager-dispatcher/using/getting-started/release-notes.html?lang=en#system-requirements-and-prerequisites
ADD https://download.macromedia.com/dispatcher/download/dispatcher-apache2.4-linux-x86_64-4.3.6.tar.gz ./dispatcher/

# Extract the tar file and move it to Apache Modules folder with name mod_dispacher.so
RUN tar -xzvf ./dispatcher/dispatcher-apache2.4-linux-x86_64-4.3.6.tar.gz -C ./dispatcher && \
    cp ./dispatcher/dispatcher-apache2.4-4.3.6.so /usr/local/apache2/modules/mod_dispatcher.so

# Copy the dispacher.any file in to the Image in the below path
#COPY dispatcher.any /usr/local/apache2/conf/dispatcher.any
RUN cp ./dispatcher/conf/dispatcher.any /usr/local/apache2/conf/dispatcher.any
#RUN cp ./dispatcher/conf/author_dispatcher.any /usr/local/apache2/conf/author_dispatcher.any
#
#
## Copy the apache configuration file in the Image and paste it into the apache configuration path as mentioned below
COPY httpd.conf /usr/local/apache2/conf/httpd.conf
#RUN cp ./dispatcher/conf/httpd-dispatcher.conf /usr/local/apache2/conf/extra/
#RUN echo "LoadModule dispatcher_module  modules/mod_dispatcher.so" >> /usr/local/apache2/conf/httpd.conf
#RUN echo "Include conf/extra/httpd-dispatcher.conf" >> /usr/local/apache2/conf/httpd.conf

#Configure Dispatcher
#https://stackoverflow.com/a/5171935
#RUN sed -i.bak s/127.0.0.1/aem-publish/g /usr/local/apache2/conf/author_dispatcher.any

#https://masaki-blog.net/docker-apache-conf
RUN apachectl restart

#miscs
#https://stackoverflow.com/a/5171935
