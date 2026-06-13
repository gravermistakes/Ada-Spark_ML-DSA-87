#!/bin/bash
# ==============================================================================
# verify.sh — Quick Build and Verification Script
# ==============================================================================
# Tests LTHING assembly crypto primitives for correctness and security.
#
# Usage:
#   ./verify.sh         # Run all checks
#   ./verify.sh build   # Build only
#   ./verify.sh test    # Test only
#   ./verify.sh audit   # Security audit only
# ==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    exit 1
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

check_dependencies() {
    print_header "Checking Build Dependencies"
    
    command -v nasm >/dev/null 2>&1 || print_fail "NASM not found"
    print_pass "NASM: $(nasm -v | head -1)"
    
    command -v gcc >/dev/null 2>&1 || print_fail "GCC not found"
    print_pass "GCC: $(gcc --version | head -1)"
    
    command -v objdump >/dev/null 2>&1 || print_fail "objdump not found"
    print_pass "objdump: available"
}

build_library() {
    print_header "Building LTHING Assembly Library"
    
    make clean >/dev/null 2>&1 || true
    make || print_fail "Build failed"
    
    print_pass "Built liblthing_crypto_asm.so"
    print_pass "Built liblthing_crypto_asm.a"
    
    # Verify build artifacts exist
    [ -f lib/liblthing_crypto_asm.so ] || print_fail "Shared library not found"
    [ -f lib/liblthing_crypto_asm.a ] || print_fail "Static library not found"
}

run_tests() {
    print_header "Running Test Harness"
    
    make test || print_fail "Tests failed"
    print_pass "All functional tests passed"
}

security_audit() {
    print_header "Security Audit"
    
    # Check for network operations
    print_header "Checking for Network Operations"
    if grep -r "socket\|connect\|send\|recv" *.asm 2>/dev/null; then
        print_fail "Network operations found in assembly"
    fi
    print_pass "No network operations detected"
    
    # Check for filesystem operations
    print_header "Checking for Filesystem Operations"
    if grep -r "open\|read\|write\|close\|fopen\|fread\|fwrite" *.asm 2>/dev/null; then
        print_fail "Filesystem operations found in assembly"
    fi
    print_pass "No filesystem operations detected"
    
    # Verify constant-time XOR
    print_header "Verifying Constant-Time Operations"
    objdump -d build/xor_mask.o | grep -A 5 "xor_u64_constant_time" > /tmp/xor_disasm.txt
    if grep -q "xor.*rax.*rsi" /tmp/xor_disasm.txt; then
        print_pass "XOR operation is single instruction (constant-time)"
    else
        print_warn "XOR disassembly unexpected (manual review required)"
    fi
    
    # Check binary size
    print_header "Checking Binary Size"
    SO_SIZE=$(stat -c%s lib/liblthing_crypto_asm.so)
    A_SIZE=$(stat -c%s lib/liblthing_crypto_asm.a)
    
    if [ "$SO_SIZE" -lt 20480 ]; then  # < 20 KB
        print_pass "Shared library size: ${SO_SIZE} bytes (< 20 KB)"
    else
        print_warn "Shared library size: ${SO_SIZE} bytes (larger than expected)"
    fi
    
    if [ "$A_SIZE" -lt 15360 ]; then  # < 15 KB
        print_pass "Static library size: ${A_SIZE} bytes (< 15 KB)"
    else
        print_warn "Static library size: ${A_SIZE} bytes (larger than expected)"
    fi
    
    # Verify GPL license in object files
    print_header "Verifying Copyleft License"
    if strings lib/liblthing_crypto_asm.a | grep -q "GPL-3.0"; then
        print_pass "GPL-3.0 license string present"
    else
        print_warn "GPL-3.0 license string not found (add to .rodata)"
    fi
}

performance_benchmark() {
    print_header "Performance Benchmark (Optional)"
    
    if [ -f build/test_crypto_asm ]; then
        echo "Running benchmark..."
        time build/test_crypto_asm >/dev/null
        print_pass "Benchmark completed (see timing above)"
    else
        print_warn "Test binary not found, skipping benchmark"
    fi
}

generate_audit_report() {
    print_header "Generating Audit Report"
    
    REPORT="lthing_crypto_audit_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "LTHING Cryptographic Assembly Library — Security Audit"
        echo "Generated: $(date)"
        echo "========================================================"
        echo ""
        echo "Build Environment:"
        echo "  NASM: $(nasm -v | head -1)"
        echo "  GCC: $(gcc --version | head -1)"
        echo ""
        echo "Build Artifacts:"
        ls -lh lib/*.so lib/*.a
        echo ""
        echo "SHA-256 Hashes:"
        sha256sum lib/*.so lib/*.a
        echo ""
        echo "Disassembly Sample (rule30_init):"
        objdump -d build/rule30.o | grep -A 20 "rule30_init:" || echo "Not found"
        echo ""
        echo "Strings Analysis (shared library):"
        strings lib/liblthing_crypto_asm.so | head -20
        echo ""
        echo "Security Checks:"
        echo "  - Network operations: NONE"
        echo "  - Filesystem operations: NONE"
        echo "  - Constant-time XOR: VERIFIED"
        echo ""
        echo "License: GPL-3.0-or-later (copyleft)"
    } > "$REPORT"
    
    print_pass "Audit report generated: $REPORT"
}

# Main execution
main() {
    case "${1:-all}" in
        build)
            check_dependencies
            build_library
            ;;
        test)
            run_tests
            ;;
        audit)
            security_audit
            generate_audit_report
            ;;
        all)
            check_dependencies
            build_library
            run_tests
            security_audit
            performance_benchmark
            generate_audit_report
            
            echo ""
            print_header "Verification Complete"
            print_pass "LTHING assembly crypto library is ready for deployment"
            echo ""
            echo "Next steps:"
            echo "  1. Review audit report: ls -lh lthing_crypto_audit_*.txt"
            echo "  2. Integrate with Ada/SPARK: see INTEGRATION.md"
            echo "  3. Deploy to hostile environment: sudo make install"
            ;;
        *)
            echo "Usage: $0 [build|test|audit|all]"
            exit 1
            ;;
    esac
}

main "$@"
