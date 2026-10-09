.PHONY: all clean

all: out/greeting.txt

out/greeting.txt: src/greeting.txt
	mkdir -p out
	tr '[:lower:]' '[:upper:]' < src/greeting.txt > out/greeting.txt

clean:
	rm -rf out
SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

.PHONY: all check build test clean ci help

all: test

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "  BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

check:
	@if [ ! -d "$(SRC_DIR)" ] || [ -z "$(SOURCES)" ]; then \
		echo "ERROR: no .txt files found in $(SRC_DIR)" >&2; \
		exit 1; \
	fi
	@echo "Found $(words $(SOURCES)) source files in $(SRC_DIR)"

build: $(OUTPUTS)

test: build
	@if grep -q '[a-z]' $(OUTPUTS) 2>/dev/null; then \
		echo "TEST FAILED: lowercase characters remain"; \
		exit 1; \
	fi
	@echo "TEST PASSED"

clean:
	rm -rf $(OUT_DIR)

ci: clean check test
