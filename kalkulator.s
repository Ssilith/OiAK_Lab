SYSEXIT = 1
SYSWRITE = 4
STDOUT = 1
SYSREAD = 3
STDIN = 0
EXIT_SUCCESS = 0
MENU_CHOICE_LEN = 2
BUF_SIZE = 256
RESULT_BUF_SIZE = 256
ENTRY_BUF_SIZE = 1
SIGN_BUF_SIZE = 2

.align 32
.data
        first_number: .space BUF_SIZE
        second_number: .space BUF_SIZE
        result: .space RESULT_BUF_SIZE
        entry_buf: .space ENTRY_BUF_SIZE
        menu_choice: .space MENU_CHOICE_LEN
        sign: .space SIGN_BUF_SIZE
        print_sign: .space ENTRY_BUF_SIZE
        check: .space ENTRY_BUF_SIZE
        larger: .space ENTRY_BUF_SIZE
        result_buf: .space RESULT_BUF_SIZE
        ret_div: .space RESULT_BUF_SIZE
        result_buf2: .space RESULT_BUF_SIZE
        pow_text: .asciz "%ld"

.bss
        pow: .space 4
.text
        intro: .ascii "\n ---Kalkulator---\n"
        intro_len = . - intro

        menu_text: .ascii "\n 1 Dodawanie \n 2 Odejmowanie \n 3 Mnozenie \n 4 Dzielenie \n 5 Potegowanie liczby \n 6 Silnia liczby \n Wprowadz swoj wybor: "
        menu_len = . - menu_text

        messg1: .ascii  "\n\n\nWprowadz pierwsza liczbe: "
        messg1_len = . - messg1
        messg2: .ascii  "Wprowadz druga liczbe: "
        messg2_len = . - messg2
        messg3: .ascii "\nWynik: "
        messg3_len = . - messg3
        messg4: .ascii "\nReszta: "
        messg4_len = . -messg4
        messg5: .ascii "\nWprowadz potege: "
        messg5_len = . -messg5


.global main
main:
        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $intro, %ecx
        mov $intro_len, %edx
        int $0x80

menu:
        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $menu_text, %ecx
        mov $menu_len, %edx
        int $0x80

        mov $SYSREAD, %eax
        mov $STDIN, %ebx
        mov $menu_choice, %ecx
        mov $MENU_CHOICE_LEN,%edx
        int $0x80

        movb menu_choice, %bl
        cmpb $49, %bl
        jne on2
        call read_first_number
        call read_second_number
        call addition_prep
        jmp menu

on2:
        movb menu_choice, %bl
        cmpb $50, %bl
        jne on3
        call read_first_number
        call read_second_number
        call subtraction_prep
        jmp menu

on3:
        movb menu_choice, %bl
        cmpb $51, %bl
        jne on4
        call read_first_number
        call read_second_number
        call multiplication_prep
        jmp menu

on4:
        movb menu_choice, %bl
        cmpb $52, %bl
        jne on5
        call read_first_number
        call read_second_number
        call division_prep
        jmp menu

on5:
        movb menu_choice, %bl
        cmpb $53, %bl
        jne on6
        call read_first_number
        call power
        jmp menu

on6:
        movb menu_choice, %bl
        cmpb $54, %bl
        jne exit
        call read_first_number
        call factorial
        jmp menu

exit:
        mov $SYSEXIT, %eax
        mov $EXIT_SUCCESS, %ebx
        int $0x80


#Zczytywanie pierwszej liczby
read_first_number:
        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $messg1, %ecx
        mov $messg1_len, %edx
        int $0x80

        xorl %esi,%esi
        movl $255,%edi

        movb $'0', sign(%esi)

        enter_next_digit:
                mov $SYSREAD, %eax
                mov $STDIN, %ebx
                mov $entry_buf, %ecx
                mov $ENTRY_BUF_SIZE, %edx
                int $0x80

                movb entry_buf, %al
                cmpb $'-', %al
                je minus

                movb entry_buf, %al
                cmpb $'\n', %al
                je fix_number

                subb $48, %al
                movb %al, first_number(%esi)
                inc %esi
                jmp enter_next_digit

        fix_number:
                dec %esi
                dec %edi

                movb first_number(%esi), %al
                movb $0, first_number(%esi)
                movb %al, first_number(%edi)

                cmp $0, %esi
                jne fix_number
        ret

minus:
        movb $'1', sign(%esi)
        jmp enter_next_digit



#Zczytywanie drugiej liczby
read_second_number:
        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $messg2, %ecx
        mov $messg2_len, %edx
        int $0x80

        xorl %esi,%esi
        movl $255,%edi

        inc %esi
        movb $'0', sign(%esi)
        dec %esi

        enter_next_digit2:
                mov $SYSREAD, %eax
                mov $STDIN, %ebx
                mov $entry_buf, %ecx
                mov $ENTRY_BUF_SIZE, %edx
                int $0x80

                movb entry_buf, %al
                cmpb $'-', %al
                je minus2

                movb entry_buf, %al
                cmpb $'\n', %al
                je fix_number2

                subb $48, %al
                movb %al, second_number(%esi)
                inc %esi
                jmp enter_next_digit2

        fix_number2:
                dec %esi
                dec %edi

                movb second_number(%esi), %al
                movb $0, second_number(%esi)
                movb %al, second_number(%edi)

                cmp $0, %esi
                jne fix_number2
        ret

minus2:
        inc %esi
        movb $'1', sign(%esi)
        dec %esi
        jmp enter_next_digit2


#Wypisywanie wyniku
write_result:
        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $messg3, %ecx
        mov $messg3_len, %edx
        int $0x80

        xorl %esi, %esi
        find_first_not_zero:
                movb result(%esi), %al
                inc %esi

                cmpl $256, %esi
                je zero

                cmpb $0, %al
                je find_first_not_zero
        dec %esi

        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $print_sign, %ecx
        mov $ENTRY_BUF_SIZE, %edx
        int $0x80

        write_next_digit:
                movb result(%esi), %al
                addb $48, %al
                movb %al, entry_buf
                inc %esi

                mov $SYSWRITE, %eax
                mov $STDOUT, %ebx
                mov $entry_buf, %ecx
                mov $ENTRY_BUF_SIZE, %edx
                int $0x80

                cmp $255, %esi
                jne write_next_digit

        call reset_buf
        jmp menu

        zero:
                movb $'0', %al
                movb %al, entry_buf

                mov $SYSWRITE, %eax
                mov $STDOUT, %ebx
                mov $entry_buf, %ecx
                mov $ENTRY_BUF_SIZE, %edx
                int $0x80

        call reset_buf
        jmp menu



#Resetowanie buforów
reset_buf:
        xorl %esi, %esi

        movb $0, print_sign(%esi)

        reset:
        movb $0, first_number(%esi)
        movb $0, second_number(%esi)
        movb $0, result(%esi)
        movb $0, result_buf(%esi)
        movb $0, result_buf2(%esi)
        movb $0, ret_div(%esi)
        inc %esi
        cmpl $255, %esi
        jl reset
ret


#DODAWANIE
addition_prep:
        call checking_00
        cmpb $'1', check
        je addition

        call checking_11
        cmpb $'1', check
        je add_minus

        call which_is_larger
        cmpb $'0', larger
        je add_first_larger
        jne add_second_larger

        add_first_larger:
                call checking_01
                cmpb $'1', check
                jne add_first_larger_next

                jmp subtraction

                add_first_larger_next:
                        call print_minus
                        jmp subtraction

        add_second_larger:
                call change
                call checking_01
                cmpb $'1', check
                jne add_second_larger_next

                call print_minus
                jmp subtraction

                add_second_larger_next:
                        jmp subtraction

add_minus:
        call print_minus

addition:
        movl $255, %esi
        xorb %ah, %ah
        xorb %al, %al
        movb $10, %bl

        add_next_digits:
                dec %esi
                addb %al, first_number(%esi)
                movb first_number(%esi), %al
                addb second_number(%esi), %al
                xorb %ah, %ah
                div %bl
                movb %ah, result(%esi)
                cmpl $0 , %esi
                jne add_next_digits

        jmp write_result




#ODEJMOWANIE
subtraction_prep:
        call checking_01
        cmpb $'1', check
        je addition

        call checking_10
        cmpb $'1', check
        je subb_minus

        call which_is_larger
        cmpb $'0', larger
        je subb_first_larger
        jne subb_second_larger

        subb_first_larger:
                call checking_00
                cmpb $'1', check
                jne subb_first_larger_next

                jmp subtraction

                subb_first_larger_next:
                        call print_minus
                        jmp subtraction

        subb_second_larger:
                call change
                call checking_00
                cmpb $'1', check
                jne subb_second_larger_next

                call print_minus
                jmp subtraction

                subb_second_larger_next:
                        jmp subtraction

subb_minus:
        call print_minus
        jmp addition

subtraction:
        xorl %esi, %esi
        find_first_digit:
                movb first_number(%esi), %al
                inc %esi
                cmpb $0 , %al
                je find_first_digit
        dec %esi

        cmpl $254, %esi
        jne ignore

        movb first_number(%esi), %al
        subb second_number(%esi), %al
        movb %al, result(%esi)

        movl $254, %edi
        cmpb $1, ret_div(%edi)
        je ret_from_subtraction
        movb menu_choice, %bl
        cmpb $54, %bl
        je ret_factorial1

        jmp write_result

        ignore:
                movb first_number(%esi), %al
                dec %al
                movb %al, first_number(%esi)

        add_9:
                inc %esi
                movb first_number(%esi), %al
                add $9, %al
                movb %al, first_number(%esi)
                cmpl $254, %esi
                jne add_9

        movb first_number(%esi), %al
        inc %al
        movb %al, first_number(%esi)

        movl $255, %esi
        xorb %ah, %ah
        xorb %al, %al
        movb $10, %bl

        subtract_next_digits:
                dec %esi
                addb %al, first_number(%esi)
                movb first_number(%esi), %al
                subb second_number(%esi), %al
                xorb %ah, %ah
                div %bl
                movb %ah, result(%esi)
                cmpl $0 , %esi
                jne subtract_next_digits

        movl $254, %esi
        cmpb $1, ret_div(%esi)
        je ret_from_subtraction

        movb menu_choice, %bl
        cmpb $54, %bl
        je ret_factorial1

        jmp write_result



#MNOZENIE
multiplication_prep:
        call checking_01
        cmpb $'1', check
        jne next_m

        call print_minus
        jmp multiplication

        next_m:
                call checking_10
                cmpb $'1', check
                jne multiplication

        call print_minus

multiplication:
        xorl %eax, %eax
        movl $255, %edi

        loop1:
                movl $255, %esi
                movl %edi, %ebx
                dec %edi

                loop2:
                        dec %esi
                        dec %ebx

                        addb %al, result(%ebx)
                        movb first_number(%esi), %al
                        movb second_number(%edi), %cl
                        mulb %cl
                        movb $10, %cl
                        div %cl
                        addb %ah, result(%ebx)

                        cmpl $0, %esi
                        je is_edi_zero
                        jmp loop2

                is_edi_zero:
                        cmpl $0, %edi
                        jne loop1

        xorl %eax, %eax
        movl $255, %esi
        movb $10, %bl

        fix_digits:
                dec %esi
                xorb %ah, %ah
                addb %al, result(%esi)
                movb result(%esi), %al
                div %bl
                movb %ah, result(%esi)
                cmpl $0 , %esi
                jne fix_digits

        movb menu_choice, %bl
        cmpb $53, %bl
        je ret_power

        movb menu_choice, %bl
        cmpb $54, %bl
        je ret_factorial2

        jmp write_result



#DZIELENIE
division_prep:
        call checking_01
        cmpb $'1', check
        jne next_d

        call print_minus
        jmp division

        next_d:
                call checking_10
                cmpb $'1', check
                jne division
        call print_minus

division:

        movl $254, %esi
        movb $1, ret_div(%esi)
        xorl %esi, %esi

        call which_is_larger
        cmpb $'1', larger
        je print_remainder

        jmp subtraction
        ret_from_subtraction:

        call result_to_first_number

        movl $255, %esi
        xorl %eax, %eax
        movb $10, %bl

        add_one_to_result:
                dec %esi
                addb %al, result_buf(%esi)
                movb result_buf(%esi), %al
                addb ret_div(%esi), %al
                xorb %ah, %ah
                div %bl
                movb %ah, result_buf(%esi)
                cmpl $0, %esi

                jne add_one_to_result

        jmp division

print_remainder:

        xorl %esi, %esi
        result_buf_to_result:
                movb result_buf(%esi), %al
                movb %al, result(%esi)
                inc %esi
                cmpl $255,%esi
                jne result_buf_to_result


        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $messg4, %ecx
        mov $messg4_len, %edx
        int $0x80

        xorl %esi, %esi
        find_first_not_zero2:
                movb first_number(%esi), %al
                inc %esi

                cmpl $256, %esi
                je zero2

                cmpb $0, %al
                je find_first_not_zero2
        dec %esi

        write_next_digit2:
                movb first_number(%esi), %al
                addb $48, %al
                movb %al, entry_buf
                inc %esi

                mov $SYSWRITE, %eax
                mov $STDOUT, %ebx
                mov $entry_buf, %ecx
                mov $ENTRY_BUF_SIZE, %edx
                int $0x80

                cmp $255, %esi
                jne write_next_digit2

        jmp write_result

        zero2:
                movb $'0', %al
                movb %al, entry_buf

                mov $SYSWRITE, %eax
                mov $STDOUT, %ebx
                mov $entry_buf, %ecx
                mov $ENTRY_BUF_SIZE, %edx
                int $0x80
        jmp write_result

#Dodawanie minusa do wyniku
print_minus:
        movb $'-', print_sign
        ret

#Sprawdzanie znakow liczb
checking_00:
        movb $'0', check
        xor %edx, %edx
        cmpb $'0', sign(%edx)
        jne end00

        inc %edx
        cmpb $'0', sign(%edx)
        jne end00

        movb $'1', check

        end00:
                xor %edx, %edx
                ret

checking_01:
        movb $'0', check
        xor %edx, %edx
        cmpb $'0', sign(%edx)
        jne end01

        inc %edx
        cmpb $'1', sign(%edx)
        jne end01

        movb $'1', check

        end01:
                xor %edx, %edx
                ret

checking_10:
        movb $'0', check
        xor %edx, %edx
        cmpb $'1', sign(%edx)
        jne end10

        inc %edx
        cmpb $'0', sign(%edx)
        jne end10

        movb $'1', check

        end10:
                xor %edx, %edx
                ret

checking_11:
        movb $'0', check
        xor %edx, %edx
        cmpb $'1', sign(%edx)
        jne end11

        inc %edx
        cmpb $'1', sign(%edx)
        jne end11

        movb $'1', check

        end11:
                xor %edx, %edx
                ret

#Sprawdzanie ktora liczba jest wieksza
which_is_larger:
        xorl %esi, %esi
        first_number_digit:
                movb first_number(%esi), %al
                inc %esi
                cmpb $0 , %al
                je first_number_digit

        movl %esi, %eax
        dec %eax

        xorl %esi, %esi
        second_number_digit:
                movb second_number(%esi), %bl
                inc %esi
                cmpb $0 , %bl
                je second_number_digit

        movl %esi, %ebx
        dec %ebx

        cmpl %eax, %ebx
        je equal_larger     #są równe
        ja first_larger     #eax jest większe
        jb second_larger     #eax jest mniejsze

        equal_larger:
                #porówanie wartości

                cmpl $255, %eax
                je first_larger

                movb first_number(%eax), %cl
                movb second_number(%eax), %dl

                inc %eax

                cmpb %cl, %dl
                je equal_larger
                ja second_larger
                jb first_larger

        end_larger:
                xorl %esi, %esi
                xorl %eax, %eax
                xorl %ebx, %ebx
                xorl %ecx, %ecx
                xorl %edx, %edx
                ret

first_larger:
         movb $'0', larger
         jmp end_larger

second_larger:
        movb $'1', larger
        jmp end_larger


#Zamiana 1 liczby z 2
change:
        xorl %esi, %esi

        change_2:
                movb first_number(%esi), %al
                movb second_number(%esi), %bl

                movb %bl, first_number(%esi)
                movb %al, second_number(%esi)

                inc %esi

                cmpl $255, %esi
                jne change_2

        xorl %esi, %esi
        xorl %eax, %eax
        xorl %ebx, %ebx
        ret

#Wpisanie wartości 1 liczby do 2
change_second_number_to_first:
        xorl %esi, %esi
        f_to_s:
                movb first_number(%esi), %al
                movb %al, second_number(%esi)
                inc %esi
                cmpl $255, %esi
                jne f_to_s
        xorl %esi, %esi
        xorl %eax, %eax
        ret

result_to_first_number:
        xorl %esi, %esi
        r_to_f:
                movb result(%esi), %al
                movb %al, first_number(%esi)
                movb $0, result(%esi)
                inc %esi
                cmpl $255, %esi
                jne r_to_f
        xorl %esi, %esi
        xorl %eax, %eax
        ret

first_number_to_result:
        xorl %esi, %esi
        f_to_r:
                movb first_number(%esi), %al
                movb %al, result(%esi)
                inc %esi
                cmpl $255, %esi
                jne f_to_r
        xorl %esi, %esi
        xorl %eax, %eax
        ret

one_to_result:
        xorl %esi, %esi
        z_to_r:
                movb $0, result(%esi)
                inc %esi
                cmpl $254, %esi
                jne z_to_r
        movb $1, result(%esi)
        xorl %esi, %esi
        xorl %eax, %eax
        ret

one_to_second_number:
        xorl %esi, %esi
        z_to_s:
           movb $0, second_number(%esi)
                inc %esi
                cmpl $254, %esi
                jne z_to_s
        movb $1, second_number(%esi)
        xorl %esi, %esi
        xorl %eax, %eax
        ret

result_buf2_to_second_number:
        xorl %esi, %esi
        rb2_to_s:
                movb result_buf2(%esi), %al
                movb %al, second_number(%esi)
                inc %esi
                cmpl $255, %esi
                jne rb2_to_s
        xorl %esi, %esi
        xorl %eax, %eax
        ret

first_number_to_result_buf2:
        xorl %esi, %esi
        f_to_rb2:
                movb first_number(%esi), %al
                movb %al, result_buf2(%esi)
                inc %esi
                cmpl $255, %esi
                jne f_to_rb2
        xorl %esi, %esi
        xorl %eax, %eax
        ret

result_to_result_buf2:
        xorl %esi, %esi
        r_to_rb2:
                movb result(%esi), %al
                movb %al, result_buf2(%esi)
                movb $0, result(%esi)
                inc %esi
                cmpl $255, %esi
                jne r_to_rb2
        xorl %esi, %esi
        xorl %eax, %eax
        ret

two_to_second_number:
        xorl %esi, %esi
        z_to_s2:
           movb $0, second_number(%esi)
                inc %esi
                cmpl $254, %esi
                jne z_to_s2
        movb $2, second_number(%esi)
        xorl %esi, %esi
        xorl %eax, %eax
        ret

zero_to_result:
        xorl %esi, %esi
        z2_to_r:
                movb $0, result(%esi)
                inc %esi
                cmpl $255, %esi
                jne z2_to_r
        xorl %esi, %esi
        xorl %eax, %eax
        ret


result_buf2_to_result:
        xorl %esi, %esi
        rb2_to_r:
                movb result_buf2(%esi), %al
                movb %al, result(%esi)
                inc %esi
                cmpl $255, %esi
                jne rb2_to_r
        xorl %esi, %esi
        xorl %eax, %eax
        ret

#POTEGOWANIE
power:
        mov $SYSWRITE, %eax
        mov $STDOUT, %ebx
        mov $messg5, %ecx
        mov $messg5_len, %edx
        int $0x80

        push %ebp
        mov %esp, %ebp

        pushl $pow
        pushl $pow_text
        call scanf
        popl %eax
        popl %eax

        mov %ebp, %esp
        pop %ebp

        xorl %eax, %eax
        cmpb $'0', sign(%eax)
        je power_next2

        xorl %edx, %edx
        movl (pow), %eax
        movl $2, %ecx
        div %ecx
        cmpl $0, %edx
        je power_next2

        call print_minus

        power_next2:
        mov (pow), %edx
        call change_second_number_to_first

        cmpl $0, %edx
        jne power_next
        call one_to_result
        jmp write_result

        power_next:
        cmpl $1, %edx
        jne power_loop
        call first_number_to_result
        jmp write_result

        power_loop:
                jmp multiplication
                ret_power:
                call result_to_first_number
                dec %edx

                cmpl $1, %edx
                jne power_loop

        call first_number_to_result
        jmp write_result

#SILNIA
factorial:
        call first_number_to_result_buf2
        factorial_loop:
                call one_to_second_number
                jmp subtraction
                ret_factorial1:
                call result_to_first_number
                call result_buf2_to_second_number

                jmp multiplication
                ret_factorial2:
                call result_to_result_buf2

                call two_to_second_number

                xorl %esi, %esi
                check_loop:
                        cmpl $254, %esi
                        je leave_check_loop

                        movb first_number(%esi), %al
                        cmpb $0, %al
                        jne leave_check_loop
                        inc %esi
                jmp check_loop

                leave_check_loop:
                cmpl $254, %esi
                jne factorial_loop
                movb first_number(%esi), %al
                cmpb $1, %al
                jne factorial_loop

        call result_buf2_to_result
        jmp write_result

