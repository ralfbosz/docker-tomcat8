FROM ralfbosz/jdk8
MAINTAINER "Ralf Bosz <ralf@bosz.com>"

ENV TOMCAT_VERSION 8.0.24
ENV CATALINA_HOME /opt/apache-tomcat-${TOMCAT_VERSION}
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

# Install APR
WORKDIR /opt

# Install Tomcat 8
RUN yum -y install epel-release gcc tar make wqy-zenhei-fontsi apr apr-devel apr-util apr-util-devel openssl-devel && \
    curl -Lkj http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz | \
    tar xz && \
    chmod +x ${CATALINA_HOME}/bin/*sh && \
    cd ${CATALINA_HOME}/bin && \
    tar xfz tomcat-native.tar.gz && \
    cd tomcat-native-*-src/jni/native/ && \
    ./configure --with-apr=/usr/bin/apr-1-config --with-java_home=${JAVA_HOME} --with-ssl=yes --prefix=${CATALINA_HOME} && \
    make && \
    make install && \
# Remove unneeded apps
    rm -rf ${CATALINA_HOME}/webapps/examples && \
    rm -rf ${CATALINA_HOME}/webapps/docs && \
    rm -rf ${CATALINA_HOME}/webapps/ROOT && \
    rm -rf ${CATALINA_HOME}/RELEASE-NOTES && \
    rm -rf ${CATALINA_HOME}/RUNNING.txt && \
    rm -rf ${CATALINA_HOME}/bin/*.bat && \
    rm -rf ${CATALINA_HOME}/bin/*.tar.gz && \
    rm -rf ${CATALINA_HOME}/bin/tomcat-native-*-src && \

# remove uneeded pkgs
    yum -y remove apr-devel apr-util-devel cyrus-sasl-devel expat-devel keyutils-libs-devel libcom_err-devel libdb-devel libselinux-devel libsepol-devel libverto-devel openldap-devel pcre-devel sysvinit-devel zlib-devel epel-release gcc make cpp glibc-devel glibc-headers libmpc mpfr && \
    yum clean all

# Create Tomcat admin user
ADD create_admin_user.sh ${CATALINA_HOME}/scripts/create_admin_user.sh
ADD tomcat.sh ${CATALINA_HOME}/scripts/tomcat.sh
RUN chmod +x ${CATALINA_HOME}/scripts/*.sh && \

# Create tomcat user
    groupadd -r tomcat && \
    useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
    chown -R tomcat:tomcat ${CATALINA_HOME} && \
    chmod -R o-rwx ${CATALINA_HOME}

EXPOSE 8080
EXPOSE 8009

USER tomcat
CMD ["tomcat.sh"]
