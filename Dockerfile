FROM ralfbosz/jdk8
MAINTAINER "Ralf Bosz <ralf@bosz.com>"

ENV TOMCAT8_URL http://mirrors.supportex.net/apache/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz
ENV JAVA_HOME /opt/jdk1.8.0_51
ENV CATALINA_HOME /opt/apache-tomcat-8.0.24
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

# Install Tomcat 8
WORKDIR /opt
RUN wget -nv ${TOMCAT8_URL} && \
    tar -xf apache-tomcat*.tar.gz && \
    rm apache-tomcat*.tar.gz && \
    chmod +x ${CATALINA_HOME}/bin/*sh

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
