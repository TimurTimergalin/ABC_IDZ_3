.include "mfunc.inc"
.include "io.inc"

# Разворачивает строку в памяти
.macro reverse_block_body  # (buffer_address, length) -> None
	add a1 a1 a0
	addi a1 a1 -1  # В a1 адрес последнего символа
	
	loop:
	bge a0 a1 end
		lb t0 (a0)
		lb t1 (a1)
		sb t1 (a0)
		sb t0 (a1)
		addi a0 a0 1
		addi a1 a1 -1
		b loop
	end:
.end_macro
func(_reverse_block, reverse_block_body)


# Одна итерация функции reverse, которая:
# 1. Читает блок из файла (см. io.inc/read_block)
# 2. Разворачивает его
# 3. Печатает результат в консоль, если нужно
# 4. Записывает результат в файл
# Изначально каретка в файле должна быть в конце
.macro iteration (%desc_in, %desc_out, %buf, %length, %print)
	read_block (%desc_in, %length, %buf)
	
	 mv a0 %buf
	 mv a1 %length
	 jal _reverse_block
	 
	 beqz %print printed
	 	mv a0 %buf
	 	li a7 4
	 	ecall
	 printed:
	 write (%desc_out, %buf, %length)
.end_macro

# Решает задачу из условия
# Аргументы:
# 	desc_in - файловый дескриптор входного файла
# 	length - длина входного файла
# 	desc_out - файловый дескриптор выходного файла
# 	buf - буфер для чтения
# 	buf_size - размер буфера
# 	print - 0/1 - выводить ли результат в консоль или нет
.macro reverse_body  # (desc_in, length, desc_out, buf, buf_size, print)
	# Будет вызываться функция - перестрахуемся и сохраним все аргументы в s-регистры,
	# тогда нужно запомнить изначальные их значения на стек 
	save (s0)
	save (s1)
	save (s2)
	save (s3)
	save (s4)
	save (s5)
	save (s6)
	save (s7)
	
	mv s0 a0
	mv s1 a1
	mv s2 a2
	mv s3 a3
	mv s4 a4
	mv s5 a5
	
	# Сначала выводим остаточный блок (самый последний, длина которого может не совпадать с длиной буфера)
	rem s6 s1 s4  # Длина последнего блока - остатка
	iteration (s0, s2, s3, s6, s5)
	
	# А затем выводим все целые блоки
	div s6 s1 s4  # Количество целых блоков
	li s7 0
	
	loop:
	bge s7 s6 end
		iteration(s0, s2, s3, s4, s5)
		addi s7 s7 1
		b loop
	end:
	restore (s7)
	restore (s6)
	restore (s5)
	restore (s4)
	restore (s3)
	restore (s2)
	restore (s1)
	restore (s0)
.end_macro
gfunc(_reverse, reverse_body)
