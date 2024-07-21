.code16
.global _start
_start:
  	jmp	realstart

.set KERNEL_SIZE_OFF, 20
.org KERNEL_SIZE_OFF

.global kernel_size
kernel_size:
	.long	_end-_start
		
realstart:
    .long 0xDEADBEEF
    // mov	$0,%ah
	  // int	$0x13

    mov $setup_msg, %si
    call bios_putstring

    jmp .

bios_putstring:
	mov	(%si), %al
	cmp	$0, %al
	jz	bios_putstring_done
        call	bios_putchar
	inc	%si
	jmp	bios_putstring
bios_putstring_done:
        ret

# bios_putchar invokes the bios to display
# one character on the screen.
	
bios_putchar:
	push	%ax
	push	%bx
        mov	$14,%ah
        mov	$1,%bl
        int	$0x10
	pop	%bx
	pop	%ax
	ret
setup_msg: .asciz "inside setup\r\n"
// stage2_start:
//   # .org 512 # second sector
//   .include "stage2.s"
//   .align 512, 0 # align by sector, going to next
// stage2_end:

// stage3_start:
//   # .org 4096 # 9th sector (4KB offset)
//   .include "stage3.s"
//   .align 512, 0
// stage3_end:
