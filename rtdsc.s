>> cat my_rtdsc.s

.data
        number: .asciz "Result: %llu \n"

.text
        .global my_rtdsc
        .type my_rtdsc, @function

my_rtdsc:
push %ebp
mov %esp, %ebp

cmp $0, %eax
jg zero
jmp else

zero:
xor %eax, %eax
cpuid
rdtsc
jmp koniec

else:
rdtscp

koniec:
push %eax
push $nubmer
call printf
pop %eax
pop %eax

mov %ebp, %esp
pop %ebp
ret



gcc -m32 my_rtdsc.s main.c -o rtdsc

as --32 -g -o rtdsc.o my_rtdsc.s
gcc -m32 -o rtdsc rtdsc.o