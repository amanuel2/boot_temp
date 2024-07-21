.code16

_read_disk:
    #**********************************************************#
    # Load disk sectors to memory (int 13h, function code 02h) #
    #----------------------------------------------------------#
    # AH	02h                                                 
    # AL	Sectors To Read Count
    # CH	Cylinder
    # CL	Sector
    # DH	Head
    # DL	Drive
    #**********************************************************#    

    call .reset
    call .drive_params

.next:

    # load es:bx (0x1000:0)
    mov $KERNEL_SEG, %ax
    mov %ax, %es
    mov $KERNEL_OFF, %bx

    # load sec 2
	mov	(disk_number), %dl
	mov	$0,%ch # cyl
	mov	$0,%dh # head
	mov	$2,%cl # sec


    lea loop_sec_msg, %si
    call puts16

### LOADING SECTOR LOOP START

.loop_init:
    mov $1, %al # we only want sec 2(1 total)
    mov $0x02, %ah
    int $0x13
    
    mov (sectors_left), %ax
    cmp $0xffff, %ax
    jne .loop_load

    # if we didnt get the sector
    # get size of kernel
    mov	%es:(KERNEL_SIZE_OFF),%eax
	shr	$9, %eax # / 2^9
	inc	%eax


.loop_load:
    dec	%ax # just read a sector
	mov	%ax,(sectors_left)
	cmp	$0, %ax
    je .done # loaded all sectors

.check:
    add $SECTOR_SIZE, %bx
    cmp $0, %bx
    jnz .next_sector

	mov	%es, %ax     # retrieve seg register
	add	$KERNEL_SEG, %ax # move to next 64k block
	mov	%ax, %es

.next_sector:
    # advance by one and check if we reached sector limit
    inc %cl # remember we started with sector #2 in %cl for second bootloader
    mov (disk_sectors), %al
    cmp %al, %cl
    jle .loop_init

    # if we reached max go back to sector 0
    # then load the next head
    mov $1, %cl
    inc %dh # next head
    mov	(disk_heads), %al
	cmp	%al, %dh
	jle	.loop_init

    # if now we reached max head then set head to 0
    # and go next cylinder
	mov	$0,%dh
	inc	%ch	# next cylinder
	mov	(disk_cylinders), %al
	cmp	%al, %ch
	jle	.loop_init

    # oh noes, now we just reached complete max !!

.done:
    call .reset
    ret

### LOADING SECTOR LOOP END

.reset:
    mov $0, %ah
    int $0x13
    ret

.drive_params:

    # AH	08h = function number for read_drive_parameters
    # DL	drive index (e.g. 1st HDD = 80h)
    # ES:DI[7]	set to 0000h:0000h to work around some buggy BIOS

    # Results
    # CF	Set On Error, Clear If No Error
    # AH	Return Code
    # DL	number of hard disk drives
    # DH[7]	logical last index of heads = number_of - 1 (because index starts with 0)
    # CX	[7:6] [15:8][7] logical last index of cylinders = number_of - 1 (because index starts with 0)
    # [5:0][7] logical last index of sectors per track = number_of (because index starts with 1)

    # BL[7]	drive type (only AT/PS2 floppies)
    # ES:DI[7]	pointer to drive parameter table (only for floppies)

    mov	$0x08, %ah
	int	$0x13
	and	$0x3f, %cl
	mov	%cl, (disk_sectors)
	mov	%ch, (disk_cylinders)
	mov	%dh, (disk_heads)
    ret

.error:
    lea err, %si
    call puts16 
    hlt

# Save the boot drive number passed by BIOS
// .global save_boot_drive
// save_boot_drive:
//     movb %dl, disk
//     ret



### DATA

err:
    .asciz "disk err"

loop_sec_msg:
    .asciz "going through loading loop...\r\n"

disk_number:
	.byte 0
disk_cylinders:
	.byte 0
disk_heads:
	.byte 0
disk_sectors:
	.byte 0

partition_status:
	.byte 0

.num_sectors:
    .word 0
.buf_off:
    .word 0
.buf_seg:
    .word 0
.lower:
    .long 0  # lower 32 of 48-bit lba
.upper:
    .long 0  # higher 32 of 48-bit lba

sectors_left:	
	.word 0xffff


###