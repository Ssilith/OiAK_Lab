SYSEXIT = 1
SYSREAD = 3
SYSWRITE = 4
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0

.align 32

.data
msg: .space 128
msg_len = . - msg

.text
.global _start

_start:
petla:
mov $0, %al
mov $SYSREAD,%eax
mov $STDIN, %ebx
mov $msg, %ecx
mov $msg_len, %edx
int $0x80

mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $msg, %ecx
mov $msg_len, %edx
int $0x80

xor %ebx, %ebx

petla_2:
inc %al
mov msg(%ebx), %cl
cmp $'\n', %cl
je wypisz

inc %ebx
jmp petla_2

wypisz:
dec %ebx
mov msg(%ebx), %cl
cmp $'Q', %cl
je out

inc %ebx
wyzerowanie:
mov $0, %cl
mov %cl, msg(%ebx)
dec %al
dec %ebx
cmp $0, %al
jne wyzerowanie

jmp petla

out:
mov $SYSEXIT, %eax
mov $EXIT_SUCCESS, %ebx
int $0x80