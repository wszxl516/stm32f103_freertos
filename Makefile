SRCROOT = ./src
PROJROOT=$(CURDIR)
# compilation flags for gdb
#CFLAGS  = -O1 -g
#ASFLAGS = -g 

# object files
BUILD_DIR=$(PROJROOT)/build
STARTUP= $(BUILD_DIR)/start.o $(BUILD_DIR)/system_stm32f10x.o 
OBJS= $(STARTUP) $(BUILD_DIR)/main.o $(BUILD_DIR)/uart.o $(BUILD_DIR)/printf.o 
OBJS+= $(BUILD_DIR)/stm32f10x_gpio.o \
	$(BUILD_DIR)/stm32f10x_rcc.o \
	$(BUILD_DIR)/stm32f10x_usart.o \
	$(BUILD_DIR)/misc.o \
	$(BUILD_DIR)/tasks.o \
	$(BUILD_DIR)/port.o \
	$(BUILD_DIR)/list.o \
	$(BUILD_DIR)/heap_4.o \
	$(BUILD_DIR)/timers.o \
	$(BUILD_DIR)/queue.o

# include common make file
# include $(SRCROOT)/Makefile.common
# Project root file

# name of executable
TARGET=$(notdir $(CURDIR))
ELF=$(TARGET).elf                    

# Library path
LIBROOT=$(PROJROOT)/lib/STM32F10x_StdPeriph_Lib_V3.5.0

# Tools
CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
AR=arm-none-eabi-ar
AS=arm-none-eabi-as
OC=arm-none-eabi-objcopy
# Code Paths
DEVICE=$(LIBROOT)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x
CORE=$(LIBROOT)/Libraries/CMSIS/CM3/CoreSupport
PERIPH=$(LIBROOT)/Libraries/STM32F10x_StdPeriph_Driver

# FreeRTOS src
BASE_DIR=lib/FreeRTOS-Kernel
RTOSSRC=$(PROJROOT)/$(BASE_DIR)
PORTFILE=$(PROJROOT)/$(BASE_DIR)/portable/GCC/ARM_CM3
MEMMANG=$(PROJROOT)/$(BASE_DIR)/portable/MemMang
RTOSINC=$(RTOSSRC)/include

# FreeRTOS config
RTOSCONFIG=$(SRCROOT)/config

# Search path for standard files
vpath %.c $(SRCROOT)

# Search path for perpheral library
vpath %.c $(CORE)
vpath %.c $(PERIPH)/src
vpath %.c $(DEVICE)

# search path for FreeRTOS source and config
vpath %.c $(RTOSSRC)
vpath %.c $(PORTFILE)
vpath %.c $(MEMMANG)

#  Processor specific
PTYPE = STM32F10X_MD_VL 
LDSCRIPT = $(SRCROOT)/stm32f103c8t6.ld

# Compilation Flags
FULLASSERT = -DUSE_FULL_ASSERT 

LDFLAGS+= -T$(LDSCRIPT) -mthumb -mcpu=cortex-m3 \
	--specs=nosys.specs -ffreestanding  \
	-mlittle-endian -mthumb-interwork \
	-flto -Wl,--Map=$(BUILD_DIR)/$(TARGET).map -g \
	-nostdlib
CFLAGS+= -mcpu=cortex-m3 -mthumb -ffreestanding -nostdlib -mlittle-endian -mthumb-interwork -g
CFLAGS+= -I$(SRCROOT) -I$(DEVICE) -I$(CORE) -I$(PERIPH)/inc -I.
CFLAGS+= -D$(PTYPE) -DUSE_STDPERIPH_DRIVER $(FULLASSERT)
CFLAGS+= -I$(RTOSINC) -I$(PORTFILE) -I. -Iinc


$(BUILD_DIR)/$(TARGET).bin : $(BUILD_DIR)/$(ELF)
	@echo [OBJCOPY] $(BUILD_DIR)/$(TARGET).bin
	@$(OC) -O binary --strip-all $(BUILD_DIR)/$(ELF) $(BUILD_DIR)/$(TARGET).bin
# Build executable 
$(BUILD_DIR)/$(ELF) : $(OBJS)
	@echo [LD] $@
	@$(LD) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

# compile and generate dependency info
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(@D)
	@echo [CC] $@
	@$(CC) -c $(CFLAGS) $< -o $@
	@$(CC) -MM $(CFLAGS) $< > $(BUILD_DIR)/$*.d

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(@D)
	@echo [AS] $@
	@$(CC) -c $(CFLAGS) $< -o $@

clean:
	@rm -fr $(BUILD_DIR)
# pull in dependencies
-include $(OBJS:.o=.d)




