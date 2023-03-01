.align 32

SYSEXIT  = 1
SYSWRITE = 4
STDOUT = 1

EXIT_SUCCESS = 0

buffer_len = 10

.bss
    .comm buffer, 9

.data
number:
    .long 123456789

.text

.global _start

_start:

    movb $'\n', (buffer + 8)

    movl (number), %ecx
    shr $0, %ecx
    andb $0xf, %cl
    cmpb $9, %cl
    call add
    movb %cl, (buffer + 7)

    movl (number), %ecx
    shr $4, %ecx
    andb $0xf, %cl
    call add
    movb %cl, (buffer + 6)

    movl (number), %ecx
    shr $8, %ecx
    andb $0xf, %cl
    call add
    movb %cl, (buffer + 5)

    movl (number), %ecx
    shr $12, %ecx
    andb $0xf, %cl
    call add
    movb %cl, (buffer + 4)

    movl (number), %ecx
    shr $16, %ecx
    andb $0xf, %cl
    call add
    movb %cl, (buffer + 3)

    movl (number), %ecx
    shr $20, %ecx
    andb $0xf, %cl
    call add
    movb %cl, (buffer + 2)

    movl (number), %ecx
    shr $24, %ecx
    andb $0xf, %cl
    call add
    movb %cl, (buffer + 1)

    movl (number), %ecx
    shr $28, %ecx
    andb $0xf, %cl
    call add
    movb %cl, (buffer)

    movl $SYSWRITE, %eax
    movl $STDOUT, %ebx
    movl $buffer, %ecx
    movl $9, %edx
    int  $0x80

    mov $SYSEXIT, %eax
    mov $EXIT_SUCCESS, %ebx
    int $0x80

add:
    cmpb $9, %cl
    jg add_af

    addb $48, %cl
    ret

add_af:
    addb $87, %cl
    ret