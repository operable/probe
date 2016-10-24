test:
	mix test

test-docker:
	docker build -t operable/probe-testing:latest . -f Dockerfile.ci
	docker run -it operable/probe-testing:latest make test

.PHONY: test
