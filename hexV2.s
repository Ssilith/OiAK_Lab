.align 32

SYSEXIT = 1
SYSWRITE = 4
SYSREAD = 3

STDOUT = 1
EXIT_SUCCESS = 0

.bss
 .comm buffer,9

.data
number:
        .long 123456789

.text

.global _start

_start:

movb $'\n', (buffer + 8)
movl number, %ecx
movl $buffer, %edi
add $8, %edi

mov $0, %bl

petla:

dec %edi
mov %ecx, %eax
shr $4, %eax
andb $0xF, %cl
call add_number
inc %bl
movb %cl, (%edi)
cmpb $8, %bl
mov %eax, %ecx
jne petla

movl $SYSWRITE, %eax
movl $STDOUT, %ebx
movl $buffer, %ecx
movl $9, %edx

int $0x80

movl $SYSEXIT, %eax
movl $EXIT_SUCCESS, %ebx

int  $0x80


add_number:
cmpb $9, %cl
jg add_hex

addb $48, %cl

ret

add_hex:

addb $87, %cl

ret