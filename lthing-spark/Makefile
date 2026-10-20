SHELL := /bin/bash
export PATH := /root/.alire/bin:$(PATH)

TOOLS_OBJ := obj_tools
TOOLS_BIN := $(TOOLS_OBJ)/bin
TOOLS_INC := -aIsrc -aIsrc/ml-dsa -aItools/provenance_seal

.PHONY: build tools test prove clean

build:
	gprbuild -P lthing.gpr

tools:
	mkdir -p $(TOOLS_OBJ) $(TOOLS_BIN)
	gnatmake -q -D $(TOOLS_OBJ) $(TOOLS_INC) -o $(TOOLS_BIN)/shake512_file tools/provenance_seal/shake512_file.adb
	gnatmake -q -D $(TOOLS_OBJ) $(TOOLS_INC) -o $(TOOLS_BIN)/sign_seal65 tools/provenance_seal/sign_seal65.adb
	gnatmake -q -D $(TOOLS_OBJ) $(TOOLS_INC) -o $(TOOLS_BIN)/verify_seal65 tools/provenance_seal/verify_seal65.adb
	gnatmake -q -D $(TOOLS_OBJ) $(TOOLS_INC) -o $(TOOLS_BIN)/rule30_salt tools/provenance_seal/rule30_salt.adb

test:
	./run_tests.sh

prove:
	gnatprove -P lthing.gpr --level=2 --report=all -j0

clean:
	rm -rf obj obj_prove obj_tests obj_tools
