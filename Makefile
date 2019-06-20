# Makefile for building development and production versions of prometheus configuration
# side kick containers

VERSION_FILE = VERSION

VERSION = $(shell cat $(VERSION_FILE) 2> /dev/null)

ifeq ($(VERSION),)
$(error VERSION is not set)
endif


DOCKER_REPOSITORY = gramal
CONTAINER_NAME = nginx-ldap-auth

.PHONY: build

build:
	docker build -f Dockerfile -t $(DOCKER_REPOSITORY)/$(CONTAINER_NAME):$(VERSION) .
	docker push $(DOCKER_REPOSITORY)/$(CONTAINER_NAME):$(VERSION)

