SYSEXIT = 1
EXIT_SUCCESS = 0
SYSWRITE = 4
STDOUT = 1

.align 32

.bss
    .comm bufor,9
bufor_len  =9

.data
number: .long 98789

.text

.global _start

_start:
movb $'\n', (bufor + 8)

mov $8, %edi
mov (number), %eax
mov $16, %ecx

petla:
dec %ebx
mov $0, %edx
div %ecx

cmp $9, %edx
jge add_more

jump:
addb $48, %edx

dec %edi
movb %dl, bufor(, %edi, 1)

cmpb $0,%eax
jne petla

movl $SYSWRITE, %eax
movl $STDOUT, %ebx
movl $bufor, %ecx
movl $bufor_len, %edx
int  $0x80

mov $SYSEXIT, %eax
mov $EXIT_SUCCESS, %ebx
int $0x80

add_more:
addb $7, %edx
jmp jump