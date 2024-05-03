CWD := $(shell pwd)

.PHONY: all
all: clean build

.PHONY: install
install: build
	@mkdir -p ~/.icons
	@cp -r result/share/icons/* ~/.icons/.
	@echo ::: INSTALL :::

.PHONY: build
build:
	@nix-build
	@echo ::: BUILD :::

.PHONY: clean
clean:
	@unlink result
	@echo ::: CLEAN :::
