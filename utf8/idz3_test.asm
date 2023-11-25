.include "convenience.inc"
.include "io.inc"
.include "mfunc.inc"
.include "reverse.inc"

.eqv SEPARATOR 92  # ЭТО ОБРАТНЫЙ СЛЭШ! ЕСЛИ У ВАС ЛИНУКС, СМЕНИТЕ НА 47 
.eqv BUFFER_SIZE 512

.data
	buf1: .space BUFFER_SIZE
	buf2: .space BUFFER_SIZE

# Реализует strncmp из stl
.macro strncmp_body  # (str1, str2, n) -> are_equal
	mv t0 a0
	mv t1 a1
	mv t2 a2
	li t5 0
	li a0 0
	
	loop:
		beq t5 t2 success
		lb t3 (t0)
		lb t4 (t1)
		
		bnez t3 stage2
		bnez t4 stage2
		b success
		stage2:
		beqz t3 end
		beqz t4 end
		addi t3 t3 1
		addi t4 t4 1
		addi t5 t5 1 
		b loop
	
	success:
	li a0 1
	end:
.end_macro
func(_strncmp, strncmp_body)
.macro strncmp (%str1, %str2, %n)
	la a0 %str1
	la a1 %str2
	li a2 %n
	jal _strncmp
.end_macro

.data
	stestcase: .asciz "Testcase "
	sok: .asciz "OK\n"
	serr: .asciz "Error: содержимое фалов не совпадает\n"

.macro testcase (%number, %fninp, %fnout, %fntest, %bufinp, %buftest, %buf_length)
	print_str (stestcase)
	li a0 %number
	print_int ()
	print_char (':')
	print_char (' ')
	
	# Разворачиаем содержимое
	openr (%fninp)
	mv s0 a0
	shift (a0)
	mv s1 a0
	openw (%fnout)
	mv s2 a0
	li s3 0
	reverse (s0, s1, s2, %bufinp, %buf_length, s3)
	
	# Закрываем файлы
	li a7 57
	mv a0 s0
	ecall
	mv a0 s2
	ecall
	
	openr (%fnout)
	mv s0 a0  # Результат
	
	openr (%fntest)
	mv s1 a0  # Правильный ответ
	
	li s2 %buf_length
	
	li a7 63
	
	loop:  # Читаем файлы и сравниваем их содержимое
	# Читаем из первого
		mv a0 s0
		la a1 %bufinp
		mv a2 s2
		ecall
		mv t0 a0
		
		# Читаем из второго
		mv a0 s1
		la a1 %buftest
		mv a2 s2
		ecall
		
		add t1 a0 t0
		
		beqz t1 success  # Оба файла дочитаны
		
		strncmp (%bufinp, %buftest, %buf_length)
	
		beqz a0 failure  # Блоки не равны
		b loop
	
	success:
		print_str (sok)
		b end
	failure:
		print_str(serr)
	
	end:
	li a7 57
	mv a0 s0
	ecall
	mv a0 s1
	ecall
.end_macro

.data
	fnout: .ascii "auto"
	       .byte SEPARATOR
	       .asciz "output.txt"
	inp1: .ascii "auto"
	       .byte SEPARATOR
	       .asciz "inp1.txt"
	test1: .ascii "auto"
	       .byte SEPARATOR
	       .asciz "test1.txt"
	inp2: .ascii "auto"
	       .byte SEPARATOR
	       .asciz "inp2.txt"
	test2: .ascii "auto"
	       .byte SEPARATOR
	       .asciz "test2.txt"
.global main
.text
main:
	testcase (1, inp1, fnout, test1, buf1, buf2, BUFFER_SIZE)
	testcase (2, inp2, fnout, test2, buf1, buf2, BUFFER_SIZE)
	exit()