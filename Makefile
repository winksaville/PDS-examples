# Makefile for Arduino CLI projects
#
# NOTE on .DELETE_ON_ERROR:
# If compile fails partway through, make deletes the target .bin so a half-written file
# doesn’t appear "up-to-date". This won’t catch: PHONY targets, tools that write/move elsewhere,
# or silent corruption (exit 0). For release/final builds, consider: make clean

# Quiet recursive make "Entering/Leaving directory" lines
MAKEFLAGS += --no-print-directory

JQ := $(shell command -v jq 2>/dev/null)
ifeq ($(JQ),)
$(error "jq not found, please install jq")
endif

# ----- user settings -----
CONFIG := ./arduino-cli.yaml
BUILD  := build
BAUD   ?= 115200
FQBN   ?= esp32:esp32:esp32s3
DTO    ?= 100ms
LFRMT  ?=                # pass `LFRMT=--json` to get JSON; `make list LFRMT=--json`
PORT   ?=                # pass `PORT=/dev/ttyXXX`; e.g. `make upload S=Foo PORT=/dev/ttyUSB0`
CLI_V  ?=                # pass `CLI_V=-v`; e.g. `make compile S=Foo CLI_V=-v`
OTHER_COMPILE_PARAMS ?=              # pass `OTHER_COMPILE_PARAMS=xx` other compile parameters such as --only-compilation-database

CLI := arduino-cli $(CLI_V) --config-file "$(CONFIG)"

# --- sketch selection: allow short var S or long SKETCH; strip trailing slash ---
SK      := $(strip $(or $(S),$(SKETCH)))
SKETCH  := $(patsubst %/,%,$(SK))

.PHONY: help init uninit lib.help list l compile upload monitor clean c u m cl
.DEFAULT_GOAL := help

INDENT := %*s
INDENT_ZR0 := 0	         # spaces to indent for right-aligned Usage/Targets help text
INDENT_PAD := 2	         # spaces to indent in Targets help text
DESC_PAD := 5		     # spaces between longest targets and description in help text

define indent
	@printf '$(INDENT)%s\n' $(1) '' $(2)
endef

define check-sketch
	@test -n "$(SKETCH)" || { echo "Error: set S=<SketchDir> (or SKETCH=)"; exit 1; }
endef

help h H: ## `make h` Show this help
	$(call indent, $(INDENT_ZR0), "Usage:")
	$(call indent, $(INDENT_PAD), "make help")
	$(call indent, $(INDENT_PAD), "make <target> {SKETCH|S}=<SketchDir>")
	$(call indent, $(INDENT_ZR0), "Examples:")
	$(call indent, $(INDENT_PAD), "make compile  SKETCH=Simple_Button_Control");
	$(call indent, $(INDENT_PAD), "make c S=Simple_Button_Control");
	$(call indent, $(INDENT_ZR0), "")
	$(call indent, $(INDENT_ZR0), "Notes:")
	$(call indent, $(INDENT_PAD), "- <SketchDir> must be a subdir containing <SketchDir>/<SketchDir>.ino")
	$(call indent, $(INDENT_PAD), "- Trailing '/' after the sketch name is accepted")
	$(call indent, $(INDENT_ZR0), "")
	$(call indent, $(INDENT_ZR0), "Targets:")
	@awk -v indent_pad=$(INDENT_PAD) -v desc_pad=$(DESC_PAD) -f support/target-list.awk $(lastword $(MAKEFILE_LIST))

init: ## `make init` One-time: init config, install core + libs
	$(CLI) config init
	$(CLI) config set directories.data shared/data
	$(CLI) config set directories.user shared
	$(CLI) config set directories.downloads shared/downloads
	$(CLI) config set network.connection_timeout 600s
	$(CLI) config add board_manager.additional_urls https://espressif.github.io/arduino-esp32/package_esp32_index.json
	$(CLI) core update-index
#	$(CLI) core install "esp32:esp32@2.0.10"	# Complex works.
#	$(CLI) core install "esp32:esp32@2.0.14"	# Complex works. Version with mbedtls_md5_xxx_ret routines PD_Stepper_Web_Server compiles OK may fail to upload
	$(CLI) core install "esp32:esp32"		# Complex works. Latest version with mbedtls_md5_xxx routines PD_Stepper_Web_Server won't compile
	$(CLI) lib install "ESPAsyncWebServer"
	$(CLI) lib install "TMC2209"

uninit: ## `make unint` Remove all files/dirs created by running `make init`
	rm -rf arduino-cli.yaml build shared

lib.help: ## `make lib.help` Show lib help
	$(CLI) lib --help

lib.%: ## `make lib.<cmd> PKG=<PackageName>` Runs arduino-cli lib <cmd> "$(PKG)"
	$(CLI) lib $(@:lib.%=%) $(if $(PKG),"$(PKG)")

list l: ## `make l` List connected boards
	$(CLI) board list $(LFRMT) --discovery-timeout "$(DTO)"

core.%: ## `make lib.<cmd> PKG=<PackageName>` Runs arduino-cli lib <cmd> "$(PKG)"
	$(CLI) core $(@:core.%=%) $(if $(PKG),"$(PKG)")

# delete half-baked binary if compile fails
.DELETE_ON_ERROR: $(BUILD)/$(SKETCH).ino.bin

# Build product from ./<SKETCH>/<SKETCH>.ino
# Note: the `--build-property "compiler.c.elf.extra_flags=\"-Wl,--wrap=app_main\""`
#       causes the linker to use our `__wrap_app_main` main.cpp in place of
#       `app_main`, the default version which is defined in:
#            PDS-examples/shared/data/packages/esp32/hardware/esp32/3.3.2/cores/esp32/main.cpp
#       The linker re-names it `__real_app_main` if we wanted to call it we could
#       by adding `extern "C" void __real_app_main(void);` and then invoking __real_app_main.
# 	    well, but we don't need to.
#       See this conversation with the Bot how we came to this solution
#       https://chatgpt.com/share/68fc169e-d0e4-800c-b570-2f43e7ca48bb
#
#	For Debug_Aux we must'n use --wrap, hence the conditional
.PHONY: buildit
buildit:
	@if [[ "$(SKETCH)" == "Debug_Aux" ]]; then \
		$(CLI) compile -b "$(FQBN)" --build-path "$(BUILD)" "./$(SKETCH)" $(OTHER_COMPILE_PARAMS); \
	else \
		$(CLI) compile -b "$(FQBN)" --build-path "$(BUILD)" --build-property "compiler.c.elf.extra_flags=\"-Wl,--wrap=app_main\""  "./$(SKETCH)" $(OTHER_COMPILE_PARAMS); \
	fi

compile c: ## `make c S=<SketchDir>` Compile a sketch
	$(call check-sketch)
	@$(MAKE) buildit

compile_commands cc: ## `make cc S=<SketchDir>` Generate `build/compile_commands.json` using --only-compilation-database
	$(call check-sketch)
	@$(MAKE) buildit OTHER_COMPILE_PARAMS=--only-compilation-database

# Helper: resolve port (use PORT if set, else auto-detected), then run $(1)
define GET_PORT
	@P="$$( [ -n "$(PORT)" ] && printf "%s" "$(PORT)" \
	      || $(CLI) board list --discovery-timeout "$(DTO)" --json | jq -r '.detected_ports[0]?.port.address // empty' )"; \
	test -n "$$P" || { echo "Error: no serial port detected. Set PORT=/dev/ttyXXX"; exit 1; }; \
	$(1)
endef

upload u: compile ## `make u S=<SketchDir>` Compile if needed and Upload, (requires S or SKETCH, optional PORT)
	$(call GET_PORT,$(CLI) upload -p "$$P" -b "$(FQBN)" --input-dir "$(BUILD)")

monitor m: ## `make m {PORT=<port> BAUD=<baudrate>` Open serial monitor optional; PORT=auto-detected, BAUD=115200)
	$(call GET_PORT,$(CLI) monitor -p "$$P" -c baudrate="$(BAUD)")

clean cl: ## `make cl` Remove build artifacts
	rm -rf -- "$(BUILD)"
