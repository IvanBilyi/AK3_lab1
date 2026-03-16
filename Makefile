# Налаштування інструментів (Toolchain)
# Визначає префікс для команд ARM (компілятор, лінкер)
SDK_PREFIX = arm-none-eabi-
# Задає компілятор (gcc)
CC         = $(SDK_PREFIX)gcc
# Задає утиліту для копіювання, конвертації об'єктних файлів
OBJCOPY    = $(SDK_PREFIX)objcopy
# Вказує повний шлях до виконуваного файлу емулятора QEMU
QEMU       = ~/opt/xPacks/qemu-arm/xpack-qemu-arm-7.2.0-1/bin/qemu-system-gnuarmeclipse

# Параметри проекту та заліза 
BOARD      = STM32F4-Discovery
MCU        = STM32F407VG
TARGET     = firmware
CPU_CC     = cortex-m4
TCP_ADDR   = 1234

# Основна ціль 
all:
	# 1. Компіляція: перетворює файл асемблера (start.S) в об'єктний файл (start.o)
	# -x assembler-with-cpp: дозволяє використовувати препроцесор C в асемблері
	# -mcpu=$(CPU_CC) -mthumb: вказує архітектуру Cortex-M4 та режим Thumb
	$(CC) -x assembler-with-cpp -c -O0 -g3 -mcpu=$(CPU_CC) -mthumb -Wall start.S -o start.o
	
	# 2. Лінкування: збирає об'єктний файл у виконуваний файл .elf
	# -T./lscript.ld: використовує скрипт лінкера для розподілу пам'яті
	# --specs=nosys.specs -nostdlib: вимикає стандартні бібліотеки
	$(CC) start.o -mcpu=$(CPU_CC) -mthumb -Wall --specs=nosys.specs -nostdlib -lgcc -T./lscript.ld -o $(TARGET).elf

# Ціль для запуску емулятора
qemu:
	# Конвертує виконуваний файл .elf у чистий бінарний файл .bin для емулятора
	$(OBJCOPY) -O binary -F elf32-littlearm $(TARGET).elf $(TARGET).bin
	
	# Запуск емулятора QEMU
	# --nographic: запуск без графічного вікна
	# -gdb tcp::$(TCP_ADDR): відкриває порт 1234 для підключення відлагоджувача GDB
	# -S: зупиняє процесор при старті, щоб ми могли підключитися і почати step-by-step
	$(QEMU) --nographic --verbose --board $(BOARD) --mcu $(MCU) -d unimp,guest_errors --image $(TARGET).bin --semihosting-config enable=on,target=native -gdb tcp::$(TCP_ADDR) -S

# Ціль для очищення
clean:
	# Видаляє всі створені під час збірки файли (.o, .elf, .bin)
	rm -f *.o *.elf *.bin
