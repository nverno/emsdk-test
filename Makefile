SHELL   := /bin/bash

export
SCRIPTS     := $(CURDIR)/scripts
TEMPDIR     := $(CURDIR)/temp
DESTDIR     ?= $(TEMPDIR)
EMSDK_DIR   =  ${DESTDIR}/emsdk
GLSLANG_DIR =  ${DESTDIR}/glslang

EMSDK_VERSION ?= latest

CMAKE_URL = https://github.com/Kitware/CMake/releases/download/v3.17.0/cmake-3.17.0-Linux-x86_64.tar.gz

.PHONY: clean help setup deps
all: emsdk-activate glslang ## Install both emscripten SDK & glslang
	@

deps: ## Install dependencies -- cmake v3.13.5+ for add_link_options
# mkdir cmake && travis_retry
	mkdir cmake && wget -qO- ${CMAKE_URL} | tar --strip-components=1 -xz -C cmake

setup:                      ## Setup install location
	@mkdir -p ${DESTDIR}

emsdk-%: setup              ## Install emscripten SDK
	${SCRIPTS}/emsdk $* ${EMSDK_VERSION}

glslang: setup              ## Install glslang
	${SCRIPTS}/glslang

glslang-web: setup          ## Install glslang web subset
	${SCRIPTS}/glslang web

test: all
	@. ${EMSDK_DIR}/emsdk_env.sh;       \
	emcc test/test.cpp -o test/test.js; \
	node test/test.js

clean:                      ## basic cleanup
	$(RM) *~

distclean: clean            ## Remove temp
	$(RM) -r ${TEMPDIR}

help:                       ## Show help for targets
	@grep -E '^[/.%0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |     \
	sort | awk                                                      \
	'BEGIN {FS = ":[^:#]*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
