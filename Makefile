TARGET = $(notdir $(CURDIR))

DEFINES += STM32F10X_MD_VL
DEFINES += GCC_ARMCM3
DEFINES += VECT_TAB_FLASH

AS = arm-none-eabi-gcc
CC = arm-none-eabi-gcc
LD = arm-none-eabi-gcc
CP = arm-none-eabi-objcopy
SZ = arm-none-eabi-size

CMSIS_PATH = CMSIS
LIBS_INC_PATH = Libs/Include
LIBS_SRC_PATH = Libs/Source

STARTUP = startup_stm32f103xb.s

SOURCEDIRS := $(LIBS_SRC_PATH)
SOURCEDIRS += $(CMSIS_PATH)
SOURCEDIRS += $(CURDIR)

INCLUDES += $(CURDIR)
INCLUDES += $(SOURCEDIRS) 
INCLUDES += $(CMSIS_PATH)
INCLUDES += $(LIBS_INC_PATH) 


MCFLAGS = -mcpu=cortex-m3 -mthumb -mlittle-endian --specs=nosys.specs \
		-ffunction-sections -fdata-sections -Wl,--gc-sections -nostartfiles

CFLAGS   = $(MCFLAGS) -Os -g -gdwarf-2 -Wall -c
LDFLAGS   = $(MCFLAGS) -T$(LDSCRIPT) -L$(CURDIR)

LDSCRIPT   = STM32F103XB_FLASH.ld


OBJ_DIR = $(CURDIR)/obj

AFLAGS += -ahls -mapcs-32

SOURCES = $(notdir $(wildcard $(addsuffix /*.c, $(SOURCEDIRS))))

OBJECTS = $(patsubst %.c, $(OBJ_DIR)/%.o, $(SOURCES))
OBJECTS += $(patsubst %.s, $(OBJ_DIR)/%.o, $(STARTUP))

VPATH := $(SOURCEDIRS)

TOREMOVE += *.elf *.hex *.bin
TOREMOVE += $(addsuffix /*.d, $(SOURCEDIRS))
TOREMOVE += $(patsubst %.s, %.o, $(STARTUP))
TOREMOVE += $(TARGET)
TOREMOVE += $(OBJECTS)


all: obj-dir $(TARGET).bin size clean-obj

target: $(TARGET).elf

$(TARGET).bin: $(TARGET).elf
	@$(CP) -Obinary $(TARGET).elf $(TARGET).bin

$(TARGET).hex: $(TARGET).elf
	@$(CP) -Oihex $(TARGET).elf $(TARGET).hex


size:
	@echo "---------------------------------------------------"
	@$(SZ) $(TARGET).elf

$(TARGET).elf: $(OBJECTS)
	@$(LD) $(LDFLAGS) $^ -o $@

obj-dir:
	mkdir -p $(OBJ_DIR)

clean-obj:
	rm -rf $(OBJ_DIR) *.elf

$(OBJ_DIR)/%.o: %.c
	@echo "Compilling C source =>" $<
	@$(CC) $(CFLAGS) $< -o $@
	
$(OBJ_DIR)/%.o: %.s
	@echo "Compilling ASM source =>" $<
	@$(AS) $(CFLAGS) $< -o $@

clean:
	@$(RM) -f $(TOREMOVE)  

write:
	st-flash write $(TARGET).bin 0x08000000

read:
	st-flash read ./default.bin 0x08000000 0x10000
