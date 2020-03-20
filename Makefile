SHELL   := /bin/bash

export
SCRIPTS     := $(CURDIR)/scripts
TEMPDIR     := $(CURDIR)/temp
DESTDIR     ?= $(TEMPDIR)
EMSDK_DIR   =  ${DESTDIR}/emsdk
GLSLANG_DIR =  ${DESTDIR}/glslang

EMSDK_VERSION ?= latest

.PHONY: clean help setup
all: emsdk-activate glslang ## Install both emscripten SDK & glslang
	@

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
