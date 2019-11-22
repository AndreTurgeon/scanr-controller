ARTIFACT_GROUP=scanr
ARTIFACT_ID=controller

DOCKER_REPOSITORY="515418792745.dkr.ecr.us-west-2.amazonaws.com"

MAJOR_VERSION=1
MINOR_VERSION=0

# BUILD_NUMBER is either coming from Jenkins or will be set to the git SHA1 of HEAD
ifndef BUILD_NUMBER
BUILD_NUMBER=$(shell git describe  --always --long --dirty)
endif

IMAGE_NAME=$(DOCKER_REPOSITORY)/$(ARTIFACT_GROUP)/$(ARTIFACT_ID)
# The official syntax for Semantic Versioning is to use a '+' sign before the build identifier.
# See https://semver.org/ section 10.
# Docker tags currently do NOT support the '+' character.
# See https://github.com/docker/distribution/issues/1201.
# For now, we will use the '-b' prefix to denote the build number. We also ommit the patch version.
IMAGE_TAG=$(MAJOR_VERSION).$(MINOR_VERSION)-b$(BUILD_NUMBER)



tag-build:
	git tag $(IMAGE_TAG)

build-docker:
	docker build --build-arg BUILD_VERSION=$(IMAGE_TAG) -t $(IMAGE_NAME):latest -f Dockerfile  .

test: build-docker
	docker run -it --rm --entrypoint pytest $(PROJECT):latest

run: build-docker
	docker run -it --rm -p 8080:8080 -v $(CURDIR):/workdir $(IMAGE_NAME):latest

push-to-ecr: build-docker      
	@eval $(shell aws ecr get-login --no-include-email)
	docker tag $(IMAGE_NAME):latest $(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

