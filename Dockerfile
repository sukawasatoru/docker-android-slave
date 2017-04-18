FROM openjdk:8

MAINTAINER Satoru Sukawa <sukawasatoru.github@outlook.jp>

ARG ANDROID_SDK_URL_PATH=https://dl.google.com/android/repository
ARG ANDROID_SDK_URL_FILE=tools_r25.2.3-linux.zip
ARG ARG_SDKMANAGER=
ARG ARG_JAVA_OPTS=

ENV JAVA_OPTS ${ARG_JAVA_OPTS}
ENV MAVEN_OPTS ${ARG_JAVA_OPTS}
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}
ENV TERM dumb

RUN dpkg --add-architecture i386 && \
        apt-get update && \
        apt-get install -y libc6:i386 libstdc++6:i386 zlib1g:i386 libncurses5:i386 --no-install-recommends && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        curl -O ${ANDROID_SDK_URL_PATH}/${ANDROID_SDK_URL_FILE} && \
        mkdir -m777 ${ANDROID_HOME} && \
        unzip ${ANDROID_SDK_URL_FILE} -d ${ANDROID_HOME} && \
        rm ${ANDROID_SDK_URL_FILE} && \
        echo y | sdkmanager ${ARG_SDKMANAGER} \
        'build-tools;25.0.2' \
        'build-tools;24.0.1' \
        'extras;android;m2repository' \
        'extras;google;m2repository' \
        'extras;google;google_play_services' \
        platform-tools \
        'platforms;android-21' \
        'platforms;android-22' \
        'platforms;android-23' \
        'platforms;android-24' \
        'platforms;android-25' \
        tools
