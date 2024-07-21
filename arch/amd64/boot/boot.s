.section .boot, "ax"
.global _start
_start:
# Remove this line if it's in boot.s: .global _start
.long 0xDEADBEEF
stage1_start:
#  .space 90 # BIOS PARAM BLOCK (when not using linker)
  .include "stage1.s"
stage1_end:

stage2_start:
  # .org 512 # second sector
  .include "stage2.s"
  .align 512, 0 # align by sector, going to next
stage2_end:

stage3_start:
  # .org 4096 # 9th sector (4KB offset)
  .include "stage3.s"
  .align 512, 0
stage3_end:
