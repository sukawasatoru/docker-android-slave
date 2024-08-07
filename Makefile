SHELL=/bin/bash
.SUFFIXES:

.PHONY: all
all:
	: do nothing.

BUILD_DOCKER_LABEL=latest
.PHONY: build-docker
build-docker:
	docker build --platform=linux/amd64 -t ghcr.io/sukawasatoru/toolchain-android:$(BUILD_DOCKER_LABEL) .
