FROM  thyrlian/android-sdk:2.6  as build-android-sdk-env
WORKDIR /opt

FROM  node:8.16-stretch  as build-node-env
WORKDIR /usr/local/bin

FROM jenkins/jnlp-slave:3.29-1

USER root:root

# Adjust china time zone
RUN ap  update \
    && apt  install -y  tzdata \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Install oracle jdk8
RUN  mkdir /usr/local/jdk
RUN  wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" -P /usr/local/jdk  http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz  && \
    tar -zxf /usrl/local/jdk/jdk-8u131-linux-x64.tar.gz -C /usr/local && \
    rm -f /usr/local/jdk/jdk-8u131-linux-x64.tar.gz 

ENV  JAVA_HOME=/usr/local/jdk1.8.0_131
ENV  CLASSPATH=$JAVA_HOME/bin
ENV  PATH="$JAVA_HOME/bin:$PATH"

# Install maven 3.6.1
RUN wget http://mirrors.sonic.net/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz && \
    tar -zxf apache-maven-3.6.1-bin.tar.gz && \
    mv apache-maven-3.6.1 /usr/local && \
    rm -f apache-maven-3.6.1-bin.tar.gz && \
    ln -s /usr/local/apache-maven-3.6.1/bin/mvn /usr/bin/mvn && \
    ln -s /usr/local/apache-maven-3.6.1 /usr/local/apache-maven

COPY --from=build-android-sdk-env /opt /opt

ENV ANDROID_HOME /opt/android-sdk \
    && GRADLE_HOME /opt/gradle  \
    && KOTLIN_HOME /opt/kotlinc \
    && PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin \
    && LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

COPY --from=build-node-env /usr/local/bin  /usr/local/bin 
COPY --from=build-node-env /usr/local/lib  /usr/local/lib
COPY --from=build-node-env /opt/yarn-v1.15.2  /opt/yarn-v1.15.2

ENTRYPOINT ["jenkins-slave"]
