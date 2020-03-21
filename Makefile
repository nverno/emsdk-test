SHELL   := /bin/bash

export
SCRIPTS     := $(CURDIR)/scripts
TEMPDIR     := $(CURDIR)/temp
DESTDIR     ?= $(TEMPDIR)
EMSDK_DIR   =  ${DESTDIR}/emsdk
GLSLANG_DIR =  ${DESTDIR}/glslang

EMSDK_VERSION ?= latest

CMAKE_VERSION  = 3.17.0
CMAKE_RELEASES = https://github.com/Kitware/CMake/releases/download
CMAKE_TARBALL  = cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz
CMAKE_URI      = ${CMAKE_RELEASES}/v${CMAKE_VERSION}/${CMAKE_TARBALL}

.PHONY: clean help setup deps
all: emsdk-activate glslang ## Install both emscripten SDK & glslang
	@

deps: ## Install dependencies -- cmake v3.13.5+ for add_link_options
	wget -qO- ${CMAKE_URI} | tar xzf -
	export PATH="cmake-${CMAKE_VERSION}-Linux-x86_64:$PATH"

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
