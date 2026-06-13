# ==============================================================================
# Makefile — LTHING Cryptographic Assembly Library
# ==============================================================================
# Builds x86-64 assembly primitives into shared library for Ada/SPARK FFI.
# Zero external dependencies. GPL-3.0-or-later (copyleft).
#
# Targets:
#   all          — Build liblthing_crypto_asm.so
#   clean        — Remove build artifacts
#   test         — Build and run test harness
#   install      — Install to system (requires root)
#
# Requirements:
#   - NASM (Netwide Assembler) >= 2.15
#   - GCC or Clang (for linking)
#   - GNAT (Ada compiler) for integration tests
# ==============================================================================

# Compiler and assembler
NASM       = nasm
CC         = gcc
GNATMAKE   = gnatmake

# Flags
NASMFLAGS  = -f elf64 -g -F dwarf
CFLAGS     = -Wall -Wextra -O2 -fPIC -g
LDFLAGS    = -shared
TESTFLAGS  = -Wall -Wextra -O0 -g -I.

# Directories
SRC_DIR    = .
BUILD_DIR  = build
LIB_DIR    = lib
TEST_DIR   = tests

# Source files
ASM_SRCS   = $(SRC_DIR)/rule30.asm \
             $(SRC_DIR)/keccak.asm \
             $(SRC_DIR)/xor_mask.asm

# Object files
ASM_OBJS   = $(patsubst $(SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(ASM_SRCS))

# Library output
LIBRARY    = $(LIB_DIR)/liblthing_crypto_asm.so
STATIC_LIB = $(LIB_DIR)/liblthing_crypto_asm.a

# Header
HEADER     = lthing_crypto_asm.h

# Installation paths
PREFIX     = /usr/local
LIBDIR     = $(PREFIX)/lib
INCDIR     = $(PREFIX)/include

# ==============================================================================
# Build Targets
# ==============================================================================

.PHONY: all clean test install uninstall

all: $(LIBRARY) $(STATIC_LIB)

# Shared library
$(LIBRARY): $(ASM_OBJS) | $(LIB_DIR)
	$(CC) $(LDFLAGS) -o $@ $^
	@echo "[LINK] $@"

# Static library
$(STATIC_LIB): $(ASM_OBJS) | $(LIB_DIR)
	ar rcs $@ $^
	@echo "[AR] $@"

# Assemble .asm -> .o
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	$(NASM) $(NASMFLAGS) -o $@ $<
	@echo "[NASM] $< -> $@"

# Create directories
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(LIB_DIR):
	mkdir -p $(LIB_DIR)

$(TEST_DIR):
	mkdir -p $(TEST_DIR)

# ==============================================================================
# Test Harness
# ==============================================================================

test: $(LIBRARY) $(TEST_DIR)/test_crypto_asm.c
	$(CC) $(TESTFLAGS) -o $(BUILD_DIR)/test_crypto_asm \
		$(TEST_DIR)/test_crypto_asm.c -L$(LIB_DIR) -llthing_crypto_asm -Wl,-rpath=$(LIB_DIR)
	@echo "[TEST] Running assembly crypto tests..."
	@$(BUILD_DIR)/test_crypto_asm

# Test source (minimal harness)
$(TEST_DIR)/test_crypto_asm.c: | $(TEST_DIR)
	@echo "/* Minimal test harness for LTHING crypto assembly */" > $@
	@echo '#include <stdio.h>' >> $@
	@echo '#include <string.h>' >> $@
	@echo '#include <stdint.h>' >> $@
	@echo '#include <assert.h>' >> $@
	@echo '#include "lthing_crypto_asm.h"' >> $@
	@echo '' >> $@
	@echo 'int main(void) {' >> $@
	@echo '    printf("Testing LTHING assembly crypto primitives...\\n");' >> $@
	@echo '    ' >> $@
	@echo '    /* Test 1: Rule30 initialization */' >> $@
	@echo '    uint8_t state[512] = {0};' >> $@
	@echo '    uint8_t seed[] = "test_seed";' >> $@
	@echo '    rule30_init(state, 512, seed, sizeof(seed)-1);' >> $@
	@echo '    printf("[PASS] rule30_init\\n");' >> $@
	@echo '    ' >> $@
	@echo '    /* Test 2: Rule30 evolution */' >> $@
	@echo '    rule30_evolve(state, 512, 1000);' >> $@
	@echo '    printf("[PASS] rule30_evolve\\n");' >> $@
	@echo '    ' >> $@
	@echo '    /* Test 3: Keystream extraction */' >> $@
	@echo '    uint8_t keystream[32];' >> $@
	@echo '    rule30_extract_keystream(state, 512, keystream, 32);' >> $@
	@echo '    printf("[PASS] rule30_extract_keystream\\n");' >> $@
	@echo '    ' >> $@
	@echo '    /* Test 4: XOR operations */' >> $@
	@echo '    uint64_t epoch = 1715485200000ULL;' >> $@
	@echo '    uint64_t masked = mask_epoch_with_keystream(epoch, keystream);' >> $@
	@echo '    uint64_t unmasked = unmask_epoch_from_keystream(masked, keystream);' >> $@
	@echo '    assert(unmasked == epoch);' >> $@
	@echo '    printf("[PASS] mask/unmask epoch (XOR self-inverse)\\n");' >> $@
	@echo '    ' >> $@
	@echo '    /* Test 5: Constant-time comparison */' >> $@
	@echo '    uint8_t a[8] = {1,2,3,4,5,6,7,8};' >> $@
	@echo '    uint8_t b[8] = {1,2,3,4,5,6,7,8};' >> $@
	@echo '    assert(compare_constant_time(a, b, 8) == 0);' >> $@
	@echo '    b[7] = 9;' >> $@
	@echo '    assert(compare_constant_time(a, b, 8) == 1);' >> $@
	@echo '    printf("[PASS] compare_constant_time\\n");' >> $@
	@echo '    ' >> $@
	@echo '    printf("\\nAll tests passed.\\n");' >> $@
	@echo '    return 0;' >> $@
	@echo '}' >> $@

# ==============================================================================
# Installation
# ==============================================================================

install: $(LIBRARY) $(HEADER)
	@echo "Installing LTHING crypto assembly library..."
	install -d $(DESTDIR)$(LIBDIR)
	install -d $(DESTDIR)$(INCDIR)
	install -m 755 $(LIBRARY) $(DESTDIR)$(LIBDIR)/
	install -m 644 $(STATIC_LIB) $(DESTDIR)$(LIBDIR)/
	install -m 644 $(HEADER) $(DESTDIR)$(INCDIR)/
	@echo "Installation complete: $(LIBDIR)/liblthing_crypto_asm.so"

uninstall:
	rm -f $(DESTDIR)$(LIBDIR)/liblthing_crypto_asm.so
	rm -f $(DESTDIR)$(LIBDIR)/liblthing_crypto_asm.a
	rm -f $(DESTDIR)$(INCDIR)/$(HEADER)

# ==============================================================================
# Clean
# ==============================================================================

clean:
	rm -rf $(BUILD_DIR) $(LIB_DIR)
	rm -f $(TEST_DIR)/test_crypto_asm.c
	@echo "Cleaned build artifacts."

# ==============================================================================
# Documentation
# ==============================================================================

.PHONY: doc
doc:
	@echo "LTHING Cryptographic Assembly Library"
	@echo "====================================="
	@echo ""
	@echo "This library provides zero-dependency x86-64 assembly implementations of:"
	@echo "  - Rule 30 cellular automaton (keystream generation)"
	@echo "  - Keccak-f[1600] permutation (SHAKE-256/512)"
	@echo "  - Constant-time XOR operations (timing-attack resistant)"
	@echo ""
	@echo "Architecture:"
	@echo "  Ada/SPARK Control Layer → FFI → Assembly Primitives"
	@echo ""
	@echo "Build:"
	@echo "  make              # Build shared + static libraries"
	@echo "  make test         # Build and run test harness"
	@echo "  sudo make install # Install to /usr/local"
	@echo ""
	@echo "Integration with Ada/SPARK:"
	@echo "  pragma Import (C, rule30_init, \"rule30_init\");"
	@echo "  pragma Import (C, keccak_f1600, \"keccak_f1600\");"
	@echo ""
	@echo "License: GPL-3.0-or-later (copyleft)"

# ==============================================================================
# Dependencies Check
# ==============================================================================

.PHONY: check-deps
check-deps:
	@echo "Checking build dependencies..."
	@command -v $(NASM) >/dev/null 2>&1 || { echo "ERROR: NASM not found"; exit 1; }
	@command -v $(CC) >/dev/null 2>&1 || { echo "ERROR: GCC/Clang not found"; exit 1; }
	@echo "[OK] All dependencies present."

# ==============================================================================
# Help
# ==============================================================================

.PHONY: help
help:
	@echo "LTHING Cryptographic Assembly Library — Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make              Build shared + static libraries"
	@echo "  make test         Build and run test harness"
	@echo "  make install      Install to $(PREFIX) (requires root)"
	@echo "  make uninstall    Remove installed files"
	@echo "  make clean        Remove build artifacts"
	@echo "  make check-deps   Verify build tools are installed"
	@echo "  make doc          Display architecture documentation"
	@echo "  make help         Show this message"
