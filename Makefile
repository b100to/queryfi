# Project variables
PROJECT_NAME=queryfi
PROJECT_VERSION=0.1.0

# Docker variables
DOCKER_REGISTRY=
DOCKER_REPOSITORY=$(PROJECT_NAME)
DOCKER_IMAGE=$(DOCKER_REGISTRY)$(DOCKER_REPOSITORY):$(PROJECT_VERSION)
DOCKER_BUILD_CONTEXT=.
DOCKER_BUILD_TARGET=development
DOCKER_COMPOSE_FILE=docker-compose.yml

.PHONY: help
help:
	@echo "Usage: make [command]"
	@echo ""
	@echo "Available commands:"
	@echo "  setup                      Setup development environment"
	@echo "  clean                      Clean up development environment"
	@echo "  format                     Format code using black"
	@echo "  lint                       Lint code using flake8"
	@echo "  build                      Build Docker image"
	@echo "  push                       Push Docker image to registry"
	@echo "  run                        Run Docker container using Docker Compose"
	@echo "  stop                       Stop Docker container using Docker Compose"
	@echo ""

.PHONY: setup
setup:
	pip install -r requirements-dev.txt

.PHONY: clean
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} \;
	find . -type f -name "*.pyc" -exec rm -f {} \;

.PHONY: format
format:
	black app tests

.PHONY: lint
lint:
	flake8 app tests

.PHONY: build
build:
	docker build \
		-t $(DOCKER_IMAGE) \
		-f Dockerfile \
		--target $(DOCKER_BUILD_TARGET) \
		--build-arg VERSION=$(PROJECT_VERSION) \
		--build-arg APP_HOME=/app \
		$(DOCKER_BUILD_CONTEXT)

.PHONY: push
push:
	docker push $(DOCKER_IMAGE)

.PHONY: run
run:
	docker-compose -f $(DOCKER_COMPOSE_FILE) up -d

.PHONY: stop
stop:
	docker-compose -f $(DOCKER_COMPOSE_FILE) down
