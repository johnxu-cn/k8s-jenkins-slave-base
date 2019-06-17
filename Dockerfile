FROM  thyrlian/android-sdk:2.6  as build-android-sdk-env
WORKDIR /opt

FROM  node:8.16-stretch  as build-node-env
WORKDIR /usr/local/bin

FROM mzagar/jenkins-slave-jdk-maven-git:latest
RUN apt update \
    && apt install -y  tzdata \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY --from=build-android-sdk-env /opt /opt

ENV ANDROID_HOME /opt/android-sdk \
    && GRADLE_HOME /opt/gradle  \
    && KOTLIN_HOME /opt/kotlinc \
    && PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin \
    && LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

COPY --from=build-node-env /usr/local/bin  /usr/local/bin 
COPY --from=build-node-env /usr/local/lib  /usr/local/lib
COPY --from=build-node-env /opt/yarn-v1.15.2  /opt/yarn-v1.15.2

WORKDIR /optCMD ["/usr/sbin/sshd", "-D"]