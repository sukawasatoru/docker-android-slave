# syntax=docker/dockerfile:1.3

FROM ubuntu:24.04 AS prepare-curl
RUN rm /etc/apt/apt.conf.d/docker-clean && \
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt \
  apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  unzip

FROM prepare-curl AS prepare-jdk
RUN --mount=type=cache,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt \
  apt-get update && apt-get install -y --no-install-recommends openjdk-17-jdk

FROM prepare-jdk AS sdkmanager
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
RUN mkdir $ANDROID_HOME
RUN curl -O https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
RUN unzip -d $ANDROID_HOME commandlinetools-linux-11076708_latest.zip
RUN echo y | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME 'cmdline-tools;latest'

FROM sdkmanager AS sdkmanager-build-tools
RUN sdkmanager 'build-tools;35.0.0'

FROM sdkmanager AS sdkmanager-emulator
RUN sdkmanager 'emulator'

FROM sdkmanager AS sdkmanager-platform-tools
RUN sdkmanager 'platform-tools'

FROM sdkmanager AS sdkmanager-platforms
RUN sdkmanager 'platforms;android-34'

FROM sdkmanager AS sdkmanager-ndk
RUN sdkmanager 'ndk;26.3.11579264'

FROM prepare-jdk
# https://source.android.com/docs/setup/start/requirements#install-packages
RUN --mount=type=cache,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt \
  apt-get update && apt-get install -y --no-install-recommends \
  bison \
  build-essential \
  flex \
  fontconfig \
  git-core \
  gnupg \
  lib32z1-dev \
  libc6-dev-i386 \
  libgl1-mesa-dev \
  libx11-dev \
  libxml2-utils \
  x11proto-core-dev \
  xsltproc \
  zip \
  zlib1g-dev
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV NDK=$ANDROID_HOME/ndk/26.3.11579264
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
COPY --from=sdkmanager $ANDROID_HOME $ANDROID_HOME
COPY --from=sdkmanager-build-tools $ANDROID_HOME/build-tools $ANDROID_HOME/build-tools
COPY --from=sdkmanager-emulator $ANDROID_HOME/emulator $ANDROID_HOME/emulator
COPY --from=sdkmanager-platform-tools $ANDROID_HOME/platform-tools $ANDROID_HOME/platform-tools
COPY --from=sdkmanager-platforms $ANDROID_HOME/platforms $ANDROID_HOME/platforms
COPY --from=sdkmanager-ndk $ANDROID_HOME/ndk $ANDROID_HOME/ndk

LABEL org.opencontainers.image.source=https://github.com/sukawasatoru/docker-android-slave
