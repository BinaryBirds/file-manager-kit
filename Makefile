SHELL=/bin/bash

.PHONY: docker

baseUrl = https://raw.githubusercontent.com/BinaryBirds/github-workflows/refs/heads/main/scripts

check: symlinks language deps lint

symlinks:
	curl -s $(baseUrl)/check-broken-symlinks.sh | bash
	
language:
	curl -s $(baseUrl)/check-unacceptable-language.sh | bash
	
deps:
	curl -s $(baseUrl)/check-local-swift-dependencies.sh | bash
	
lint:
	curl -s $(baseUrl)/run-swift-format.sh | bash

fmt:
	swiftformat .

format:
	curl -s $(baseUrl)/run-swift-format.sh | bash -s -- --fix

headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash

fix-headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash -s -- --fix

build:
	swift build

release:
	swift build -c release
	
test:
	swift test --parallel

test-with-coverage:
	swift test --parallel --enable-code-coverage

clean:
	rm -rf .build

docker-tests:
	docker build -t file-manager-kit-tests . -f ./Docker/Dockerfile.testing && docker run --rm file-manager-kit-tests

docker-run:
	docker run --rm -v $(pwd):/app -it swift:6.0
