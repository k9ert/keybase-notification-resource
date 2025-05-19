.PHONY: build test clean

# Default registry and image name
REGISTRY ?= my-registry
IMAGE_NAME ?= keybase-resource
TAG ?= latest

# Full image name
FULL_IMAGE_NAME = $(REGISTRY)/$(IMAGE_NAME):$(TAG)

# Build the Docker image
build:
	docker build -t $(FULL_IMAGE_NAME) .

# Test the resource locally (requires username and paperkey)
test:
	@echo "Usage: make test USERNAME=your-username PAPERKEY='your paper key' [TEAM=your-team] [CHANNEL=your-channel]"
	@if [ -z "$(USERNAME)" ] || [ -z "$(PAPERKEY)" ]; then \
		echo "Error: USERNAME and PAPERKEY are required"; \
		exit 1; \
	fi
	./test/test-keybase-resource.sh "$(USERNAME)" "$(PAPERKEY)" "$(TEAM)" "$(CHANNEL)"

# Push the Docker image to the registry
push: build
	docker push $(FULL_IMAGE_NAME)

# Clean up
clean:
	rm -f test/input.json test/message.txt
