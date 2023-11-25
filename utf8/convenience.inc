# Макросы выхода
.macro exit
	li a7 10
	ecall
.end_macro

.macro exit (%code)
	li a7 93
	li a0 %code
	ecall
.end_macro

# Макросы вывода
.macro print_int (%num)
	mv a0 %num
	li a7 1
	ecall
.end_macro

.macro print_int
	li a7 1
	ecall
.end_macro

.macro print_char (%c)
	li a7 11
	li a0 %c
	ecall
.end_macro

.macro nl 
	print_char '\n'
.end_macro

.macro print_str (%add)
	la a0 %add
	li a7 4
	ecall
.end_macro

.macro print_double (%num)
	li a7 3
	fmv.d fa0 %num
	ecall
.end_macro

.macro print_double
	li a7 3
	ecall
.end_macro 

# swap-ы

.macro swap (%x1, %x2)
	add %x1 %x1 %x2
	sub %x2 %x1 %x2
	sub %x1 %x1 %x2
.end_macro

.macro fswap.d (%x1, %x2)
	fadd.d %x1 %x1 %x2
	fsub.d %x2 %x1 %x2
	fsub.d %x1 %x1 %x2
.end_macro
