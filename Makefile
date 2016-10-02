# Docker Image Name (is taken from package.json file)
NAME = arch-bootstrap

# Image Version (is taken from package.json file)
##VERSION = $(shell cd .; git describe --long --tags --dirty --always)
VERSION = latest

# Dockerhub Image Name 
DOCKERHUB_NAME = ac1965/$(NAME):$(VERSION)

.PHONY: all check_exists clean build

all: build

# Perform a check if Docker image exists
check_exists:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi

# Remove Docker image
clean:
	@if docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then docker rmi $(NAME):$(VERSION); fi

# Build Docker image
build:
	@echo "Making Image: $(NAME):$(VERSION)"
	@test -d $(shell pwd)/bootstrap && rm -f $(shell pwd)/bootstrap/* || install -d $(shell pwd)/bootstrap
	@docker build -t $(NAME):$(VERSION) .
	@docker run --interactive --tty --privileged --volume $(shell pwd)/bootstrap:/var/lib/bootstrap/archive:rw $(NAME):$(VERSION)

dockerhub_tag:
	@docker tag $(NAME):$(VERSION) $(DOCKERHUB_NAME)

dockerhub_push: check_exists dockerhub_tag
	@docker push $(DOCKERHUB_NAME)
