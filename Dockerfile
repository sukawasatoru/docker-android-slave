FROM ubuntu:20.04 AS prepare-curl
ARG DEBIAN_FRONTEND=noninteractive
RUN rm /etc/apt/apt.conf.d/docker-clean && \
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt \
  apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  unzip \
  xz-utils

FROM prepare-curl AS prepare-jdk
ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt \
  apt-get update && apt-get install -y \
  openjdk-11-jdk

FROM prepare-curl AS repo
ARG DEBIAN_FRONTEND=noninteractive
RUN curl -sSfO https://storage.googleapis.com/git-repo-downloads/repo

FROM prepare-jdk AS android-sdk
ARG DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
RUN mkdir $ANDROID_HOME && \
  curl -O https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip && \
  unzip -d $ANDROID_HOME commandlinetools-linux-6858069_latest.zip && \
  rm commandlinetools-linux-6858069_latest.zip
RUN echo y | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME 'cmdline-tools;latest' && \
  sdkmanager \
  'build-tools;30.0.3' \
  'platform-tools' \
  'platforms;android-27' \
  'platforms;android-28' \
  'platforms;android-29' \
  'platforms;android-30'

FROM prepare-jdk AS gradle
ARG DEBIAN_FRONTEND=noninteractive
ENV GRADLE_USER_HOME=/gradle
COPY gradle /work/gradle
COPY gradlew /work
COPY build.gradle /work
RUN cd /work && ./gradlew wrapper --gradle-version=6.1.1 --distribution-type=all && \
  ./gradlew wrapper --gradle-version=6.1.1 --distribution-type=all

FROM prepare-jdk
ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt \
  apt-get update && apt-get install -y \
  bison \
  build-essential \
  ccache \
  flex \
  fontconfig \
  g++-multilib \
  gcc-multilib \
  git-core \
  gnupg \
  lib32ncurses5-dev \
  lib32z1-dev \
  libc6-dev-i386 \
  libgl1-mesa-dev \
  libssl-dev \
  libx11-dev \
  libxml2-utils \
  python2.7 \
  python3.8 \
  x11proto-core-dev \
  xsltproc \
  zip \
  zlib1g-dev
RUN update-alternative --install /usr/bin/python python /usr/bin/python3.8 1
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
COPY --from=android-sdk $ANDROID_HOME $ANDROID_HOME
ENV GRADLE_USER_HOME=/gradle
COPY --from=gradle $GRADLE_USER_HOME/wrapper $GRADLE_USER_HOME/wrapper
RUN chmod -R a+w $GRADLE_USER_HOME
COPY --from=repo repo /usr/local/bin/repo
