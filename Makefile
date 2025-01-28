SHELL=/bin/bash
.PHONY: docker

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

check:
	./scripts/run-checks.sh

format:
	./scripts/run-swift-format.sh --fix

docker:
	docker build -t file-manager-kit-image . -f ./Docker/Dockerfile.ubuntu && docker run --rm file-manager-kit-image
