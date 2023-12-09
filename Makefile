# Path to GNU ARM Toolchain, leave empty if already in system PATH
TOOLCHAIN_ROOT =
# Path to the STM32Cube software package
VENDOR_ROOT = /home/shampletov-no/Projects/STM32CubeF4/
###############################################################################
# Project specific
TARGET = main.elf
SRC_DIR = src/
INC_DIR = inc/
# Toolchain
CC = $(TOOLCHAIN_ROOT)arm-none-eabi-gcc
DB = $(TOOLCHAIN_ROOT)gdb-multiarch

# Project sources
SRC_FILES = $(wildcard $(SRC_DIR)*.c) $(wildcard $(SRC_DIR)*/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)*.s) $(wildcard $(SRC_DIR)*/*.s)

# Update script name and path if necessary
LD_SCRIPT = STM32F429ZITx_FLASH.ld

# Project includes
INCLUDES = -I$(INC_DIR)
# Vendor includes
INCLUDES += -I$(VENDOR_ROOT)Drivers/CMSIS/Core/Include
INCLUDES += -I$(VENDOR_ROOT)Drivers/CMSIS/Device/ST/STM32F4xx/Include
INCLUDES += -I$(VENDOR_ROOT)Drivers/STM32F4xx_HAL_Driver/Inc
INCLUDES += -I$(VENDOR_ROOT)Drivers/BSP/STM32F429I-Discovery
INCLUDES += -I$(VENDOR_ROOT)Drivers/BSP/Components/ili9341

# Compiler Flags
CFLAGS = -g -O0 -Wall -Wextra -Warray-bounds -Wno-unused-parameter
CFLAGS += -mcpu=cortex-m4 -mthumb -mlittle-endian -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -DSTM32F429xx
CFLAGS += $(INCLUDES)
# Linker Flags
LFLAGS = -Wl,--gc-sections -Wl,-T$(LD_SCRIPT) --specs=rdimon.specs

###############################################################################
# This does an in-source build. An out-of-source build that places all object
# files into a build directory would be a better solution, but the goal was to
# keep this file very simple.
CXX_OBJS = $(SRC_FILES:.c=.o)
ASM_OBJS = $(ASM_FILES:.s=.o)
ALL_OBJS = $(ASM_OBJS) $(CXX_OBJS)
.PHONY: clean gdb-server_stlink gdb-server_openocd gdb-client
all: $(TARGET)
# Compile
$(CXX_OBJS): %.o: %.c
$(ASM_OBJS): %.o: %.s
$(ALL_OBJS):
	@echo "[CC] $@"
	@$(CC) $(CFLAGS) -c $< -o $@
# Link
%.elf: $(ALL_OBJS)
	@echo "[LD] $@"
	@$(CC) $(CFLAGS) $(LFLAGS) $(ALL_OBJS) -o $@
# Clean
clean:
	@rm -f $(ALL_OBJS) $(TARGET)
# Debug
gdb-server_stlink:
	@echo Starting stlink server...
	st-util
gdb-server_openocd:
	@echo Starting OpenOCD server...
	openocd -f ./openocd.cfg
gdb-client: $(TARGET)
	@echo Starting gdb client...
	$(DB) $(TARGET)