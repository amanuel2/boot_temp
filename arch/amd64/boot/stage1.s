.section .boot, "ax"
.code16

stage1_start_code:
    # Setup segs + save boot drive
    xor %ax, %ax
    mov %ax, %ss
    # Set up stack so that it starts below Main.
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    cld

    movb %dl, BOOT_DRIVE # save the C: or / drive
    movw $0x7C00, %sp # lets not override bootloader code...


advance:
    // 0x42(ext) way but can't get it working as of yet...
    // movb BOOT_DRIVE, %dl
    // call mydisk_load

    call _read_disk

    mov $KERNEL_SEG, %ax
    mov %ax, %ds # data seg
    ljmp $KERNEL_SEG, $KERNEL_OFF # code seg



#### INCLUDES FOR BOOT SECTION
// .include "a20.s"
// .include "print32.s"
.include "print16.s"
// .include "disk.s"
.include "disk_leg.s"
// .include "e820.s"
.include "gdt_pm.s"
// .include "iso9960.s"
// stage2_id: .asciz "/BOOT/STAGET.BIN;1" # iso996 path
######## Data for boot section
// .equ KERNEL_OFFSET, 0x1000
// .equ FREE_SPACE, 0x9000
.set KERNEL_SEG, 0x1000
.set KERNEL_OFF,  0x0
.set KERNEL_SIZE_OFF, 20
.set SECTOR_SIZE, 512
enter_prot_msg: .asciz "entering protected mode...\n"
pmode_msg: .asciz "Now in 32-bit protected mode!"
BOOT_DRIVE:  .byte 0
mmap_ent:    .long 0
########

.org 510
.word 0xaa55