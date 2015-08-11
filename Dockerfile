FROM ralfbosz/jdk8
MAINTAINER "Ralf Bosz <ralf@bosz.com>"

ENV TOMCAT_VERSION 8.0.24
ENV JAVA_HOME /opt/jdk1.8.0_51
ENV CATALINA_HOME /opt/apache-tomcat-${TOMCAT_VERSION}
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

# Install Tomcat 8
WORKDIR /opt
RUN wget --quiet --no-cookies http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
RUN tar -xf apache-tomcat*.tar.gz && \
    rm apache-tomcat*.tar.gz && \
#    ln -s apache-tomcat-* tomcat && \
    chmod +x ${CATALINA_HOME}/bin/*sh

# Remove unneeded apps
RUN rm -rf ${CATALINA_HOME}/webapps/examples && \
    rm -rf ${CATALINA_HOME}/webapps/docs && \
    rm -rf ${CATALINA_HOME}/webapps/ROOT && \
    rm -rf ${CATALINA_HOME}/RELEASE-NOTES && \
    rm -rf ${CATALINA_HOME}/RUNNING.txt && \
    rm -rf ${CATALINA_HOME}/bin/*.bat && \
    rm -rf ${CATALINA_HOME}/bin/*.tar.gz

# Create Tomcat admin user
ADD create_admin_user.sh ${CATALINA_HOME}/scripts/create_admin_user.sh
ADD tomcat.sh ${CATALINA_HOME}/scripts/tomcat.sh
RUN chmod +x ${CATALINA_HOME}/scripts/*.sh

# Create tomcat user
RUN groupadd -r tomcat && \
    useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
    chown -R tomcat:tomcat ${CATALINA_HOME} && \
    chmod -R o-rwx ${CATALINA_HOME}

EXPOSE 8080
EXPOSE 8009

USER tomcat
CMD ["tomcat.sh"]

ENV JAVA8_URL ""
ENV TOMCAT8_URL ""
