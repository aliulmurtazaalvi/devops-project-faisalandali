SRC_DIR := src
OUT_DIR := out

SOURCES := $(wildcard $(SRC_DIR)/*.md)
OUTPUTS := $(patsubst $(SRC_DIR)/%.md,$(OUT_DIR)/%.html,$(SOURCES))

.PHONY: all check build test clean ci deps package

all: test

ci: clean deps check test package

deps: node_modules

node_modules: package-lock.json
	npm ci
	@touch node_modules

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.html: $(SRC_DIR)/%.md package-lock.json | $(OUT_DIR) node_modules
	@echo "  BUILD $< -> $@"
	@npm run --silent build -- $< $@

check:
	@if [ ! -d "$(SRC_DIR)" ] || [ -z "$(SOURCES)" ]; then \
		echo "ERROR: no .md files found in $(SRC_DIR)" >&2; exit 1; \
	fi
	@echo "CHECK: found $(words $(SOURCES)) source files in $(SRC_DIR)"

build: $(OUTPUTS)

test: build
	@npm test --silent
	@echo "TEST PASSED"

package: test
	npm pack

clean:
	rm -rf $(OUT_DIR) *.tgz
