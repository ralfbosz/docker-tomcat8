FROM centos:centos7
MAINTAINER "Ralf Bosz <ralf.bosz@kpn.com>"

RUN yum -y install apr wget

ENV JAVA8_URL http://download.oracle.com/otn-pub/java/jdk/8u51-b16/jdk-8u51-linux-x64.tar.gz
ENV JAVA8_FILE jdk-8u45-linux-x64.tar.gz
ENV TOMCAT8_URL http://mirrors.supportex.net/apache/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24.tar.gz
ENV TOMCAT8_FILE apache-tomcat-8.0.24.tar.gz
ENV JAVA_HOME /opt/jdk1.8.0_45
ENV CATALINA_HOME /opt/apache-tomcat-8.0.24
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

# Install JDK8
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    ${JAVA8_URL} && \
    tar -xvf ${JAVA8_FILE} && \
    rm jdk*.tar.gz && \
    mv jdk* ${JAVA_HOME} \
    chown -R root:root ${JAVA_HOME} \
    alternatives --install /usr/bin/java java /opt/${JAVA_HOME}/bin/java 1 \
    alternatives --install /usr/bin/jar jar /opt/${JAVA_HOME}/bin/jar 1 \
    alternatives --install /usr/bin/javac javac /opt/${JAVA_HOME}/bin/javac 1

# Install Tomcat
RUN wget ${TOMCAT8_URL} && \
    tar -xvf ${TOMCAT8_FILE} && \
    rm apache-tomcat*.tar.gz && \
    mv apache-tomcat* ${CATALINA_HOME} \
    chmod +x ${CATALINA_HOME}/bin/*sh

# Create Tomcat admin user
ADD create_admin_user.sh ${CATALINA_HOME}/scripts/create_admin_user.sh
ADD tomcat.sh ${CATALINA_HOME}/scripts/tomcat.sh
RUN chmod +x ${CATALINA_HOME}/scripts/*.sh

# Create tomcat user
RUN groupadd -r tomcat && \
    useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
    chown -R tomcat:tomcat ${CATALINA_HOME}

WORKDIR /opt/tomcat

EXPOSE 8080
EXPOSE 8009

USER tomcat
CMD ["tomcat.sh"]
