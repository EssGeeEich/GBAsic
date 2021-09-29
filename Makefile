BUILD_DIR ?= build
TARGET    ?= out.gba

TITLE      := SAMPLEGAMEXX
GAME_CODE  := ABCD
MAKER_CODE := EF
REVISION   := 255
DEBUG_MODE := 0

DEPS_DIR   := deps
SRC_DIRS   := src
INC_DIRS   := include include/bin $(DEPS_DIR)/libgba/include

DEFINES    := 

LOCAL_CXX      := $(CXX)
LOCAL_CXX      ?= g++
LOCAL_CC       := $(CC)
LOCAL_CC       ?= gcc
LOCAL_CPPFLAGS := $(CPPFLAGS)
LOCAL_CFLAGS   := $(CFLAGS)
LOCAL_CXXFLAGS := $(CXXFLAGS)

MKDIR_P  := mkdir -p
FIND     := find
GREP     := grep
TR       := tr
SORT     := sort
HEAD     := head
TAIL     := tail
BASENAME := basename

TOOLKIT  ?= arm-none-eabi
CC       := $(TOOLKIT)-gcc
CXX      := $(TOOLKIT)-g++
AS       := $(TOOLKIT)-as
OBJCOPY  := $(TOOLKIT)-objcopy
LD       := $(TOOLKIT)-ld
GCC_LIB  ?= $(shell $(FIND) /usr/lib/gcc/$(TOOLKIT)/ -type d | $(SORT) -z | $(HEAD) -n 2 | $(TAIL) -n 1)

SRCS := $(shell $(FIND) $(SRC_DIRS) -type f \( -name *.bin \) ) $(shell $(FIND) $(SRC_DIRS) -type f \( -name *.cpp -or -name *.c -or -name *.s \) ) $(DEPS_DIR)/crtls/gba_crt0.s $(shell $(FIND) $(DEPS_DIR)/libgba/src -type f \( -name *.cpp -or -name *.c -or -name *.s \) -and -not -name *print.c -and -not -name console.c)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o) $(GCC_LIB)/crti.o $(GCC_LIB)/crtbegin.o $(GCC_LIB)/crtend.o $(GCC_LIB)/crtfastmath.o $(GCC_LIB)/crtn.o
DEPS := $(OBJS:.o=.d)

INC_ADIRS := $(INC_DIRS) $(SRC_DIRS) $(GCC_LIB)/include
INC_FLAGS := $(addprefix -I,$(INC_ADIRS))

GREP_ARG := '\(=?\"\K[^\"]*'
LINK_DIRS  := $(shell $(LD) --verbose | $(GREP) "SEARCH_DIR" | $(TR) -s ' ;' \\012 | $(GREP) -oP $(GREP_ARG) )
LINK_ADIRS := $(LINK_DIRS) $(GCC_LIB)
LINK_FLAGS := $(addprefix -L,$(LINK_ADIRS))

CPPFLAGS := -O3 -fomit-frame-pointer -marm -mcpu=arm7tdmi -pedantic -Wall $(INC_FLAGS) -MMD -MP -fno-exceptions -nostdlib -ffreestanding -fno-builtin $(DEFINES)
CFLAGS   := -std=gnu11
CXXFLAGS := -std=c++11
LIBS     := -lm -lg_nano -lc_nano -lstdc++_nano -lgcc -lgcov
LDFLAGS  := $(LINK_FLAGS) $(LIBS) -T $(DEPS_DIR)/crtls/gba_cart.ld --gc-sections
ASFLAGS  :=
GBAFIX_C := $(DEPS_DIR)/gba-tools/src/gbafix.c

all: $(BUILD_DIR)/$(TARGET)
gbafix: $(BUILD_DIR)/$(DEPS_DIR)/gba-tools/src/gbafix.c.exe
bintoc: $(BUILD_DIR)/$(DEPS_DIR)/tools/bintoc.cpp.exe

$(BUILD_DIR)/$(TARGET): $(BUILD_DIR)/$(TARGET).elf gbafix
	$(OBJCOPY) -O binary $< $@
	$(BUILD_DIR)/$(DEPS_DIR)/gba-tools/src/gbafix.c.exe $@ -p -t$(TITLE) -c$(GAME_CODE) -m$(MAKER_CODE) -r$(REVISION) -d$(DEBUG_MODE)

$(BUILD_DIR)/$(TARGET).elf: $(OBJS)
	$(LD) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.c.exe: %.c
	$(MKDIR_P) $(dir $@)
	$(LOCAL_CC) $(LOCAL_CPPFLAGS) $(LOCAL_CFLAGS) $< -o $@

$(BUILD_DIR)/%.cpp.exe: %.cpp
	$(MKDIR_P) $(dir $@)
	$(LOCAL_CXX) $(LOCAL_CPPFLAGS) $(LOCAL_CXXFLAGS) $< -o $@

$(BUILD_DIR)/%.bin.o: %.bin $(BUILD_DIR)/$(DEPS_DIR)/tools/bintoc.cpp.exe
	$(MKDIR_P) $(dir $@)
	$(MKDIR_P) include/bin
	$(BUILD_DIR)/$(DEPS_DIR)/tools/bintoc.cpp.exe $< $@.c include/bin/$(shell $(BASENAME) $< | $(GREP) -oP '[A-Za-z0-9_]+' | $(HEAD) -n 1).h $(shell $(BASENAME) $< | $(GREP) -oP '[A-Za-z0-9_]+' | $(HEAD) -n 1)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $@.c -o $@

$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

.PHONY: clean

clean:
	$(RM) -r include/bin
	$(RM) -r $(BUILD_DIR)

-include $(DEPS)
