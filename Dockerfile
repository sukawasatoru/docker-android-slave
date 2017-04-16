FROM openjdk:8

MAINTAINER Satoru Sukawa <sukawasatoru@live.com>

ENV ANDROID_SDK_URL_PATH https://dl.google.com/android/repository
ENV ANDROID_SDK_URL_FILE tools_r25.2.3-linux.zip
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}
ENV TERM dumb

# TODO: password to rsa key
RUN groupadd -r jenkins && \
        useradd -rg jenkins jenkins && \
        echo -e "1234\n1234" | passwd jenkins && \
        dpkg --add-architecture i386 && \
        apt-get update && \
        apt-get install -y \
        libc6:i386 \
        libstdc++6:i386 \
        zlib1g:i386 \
        libncurses5:i386 \
        openssh-server \
        --no-install-recommends && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* && \
        curl -O ${ANDROID_SDK_URL_PATH}/${ANDROID_SDK_URL_FILE} && \
        unzip ${ANDROID_SDK_URL_FILE} -d ${ANDROID_HOME} && \
        rm ${ANDROID_SDK_URL_FILE} && \
        echo y | sdkmanager 'build-tools;25.0.2' \
        'extras;android;m2repository' \
        'extras;google;m2repository' \
        'extras;google;google_play_services' \
        platform-tools \
        'platforms;android-21' \
        'platforms;android-22' \
        'platforms;android-23' \
        'platforms;android-24' \
        'platforms;android-25' 
        tools
RUN chown -R jenkins:jenkins /home/jenkins/.ssh && \
        chmod 700 /home/jenkins/.ssh && \
        chmod 600 /home/jenkins/.ssh/*

EXPOSE 22
CMD service ssh start
CMD bash -c "while :; do sleep 60; done"
