SRCDIR         = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL          = /bin/bash
ARGS           = $(filter-out $@,$(MAKECMDGOALS))

PHP_VERSION           ?= 7.3
PHALCON_VERSION       ?= v3.4.5
PHALCON_MAJOR_VERSION ?= 34
BUILD_ID              ?= $(shell /bin/date "+%Y%m%d-%H%M%S")

IMAGE_NAME     = gamalan/mkimage

.SILENT: ;               # no need for @
.ONESHELL: ;             # recipes execute in same shell
.NOTPARALLEL: ;          # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell
Makefile: ;              # skip prerequisite discovery

# Public targets

.PHONY: build
build: pre-build docker-build

.PHONY: pre-build
pre-build: check

.PHONY: post-build
post-build: clean

.PHONY: check
check:
ifeq ($(PHP_VERSION),)
	$(error The PHP_VERSION variable not defined: $(PHP_VERSION))
endif

.PHONY: docker-build
docker-build:
	docker buildx build \
		-t $(IMAGE_NAME):php$(PHP_VERSION)-phalcon$(PHALCON_MAJOR_VERSION) \
		--platform "linux/amd64,linux/arm64,linux/arm/v7" \
		--label build_id=$(BUILD_ID) \
		--pull \
		--build-arg PHP_VERSION=$(PHP_VERSION) \
		--build-arg PHALCON_VERSION=$(PHALCON_VERSION) \
		--push \
		--network=host \
		. \
		-f Dockerfile.build

.PHONY: release
release: build clean

.SECONDARY: clean

%:
	@:
# vim:ft=make:noet:ci:pi:sts=0:sw=4:ts=4:tw=78:fenc=utf-8:et

