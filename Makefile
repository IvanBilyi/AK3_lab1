SDK_PREFIX = arm-none-eabi-
CC         = $(SDK_PREFIX)gcc
OBJCOPY    = $(SDK_PREFIX)objcopy
QEMU       = ~/opt/xPacks/qemu-arm/xpack-qemu-arm-7.2.0-1/bin/qemu-system-gnuarmeclipse

BOARD      = STM32F4-Discovery
MCU        = STM32F407VG
TARGET     = firmware
CPU_CC     = cortex-m4
TCP_ADDR   = 1234

all:
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -mthumb -Wall start.S -o start.o
	$(CC) start.o -mcpu=$(CPU_CC) -mthumb -Wall --specs=nosys.specs -nostdlib -lgcc -T./lscript.ld -o $(TARGET).elf

qemu:
	$(OBJCOPY) -O binary -F elf32-littlearm $(TARGET).elf $(TARGET).bin
	$(QEMU) --nographic --verbose --board $(BOARD) --mcu $(MCU) -d unimp,guest_errors --image $(TARGET).bin --semihosting-config enable=on,target=native -gdb tcp::$(TCP_ADDR) -S

clean:
	rm -f *.o *.elf *.bin
