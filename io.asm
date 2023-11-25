.include "convenience.inc"
.include "mfunc.inc"

.data
	sioerr: .asciz "IO error\n"
.text


# Макрос на проверку ошибки io
# Каждый syscall, работающий с файлами, возвращает -1, если произошла лшибка
# Этот макрос проверяет значение переданного регистра на равенство -1
# В случае совпадения выводится сообщение об ошибке, и программа досрочно закрывается
.macro check_error (%reg)
	addi t6 %reg 1
	
	bnez t6 end
		li a7 55
		la a0 sioerr
		li a1 0
		ecall
		exit(2)
	end:
.end_macro

# Функция вычисления длины строки (без учёта \0)
.macro strlen_body  # (buffer_address) -> length
	mv t0 a0
	li a0 0
	loop:
	lb t1 (t0)
	beqz t1 end
		addi a0 a0 1
		addi t0 t0 1
		b loop
	end:
.end_macro
func(_strlen, strlen_body)

# Функция, убирающая символ \n с конца строки, если он есть
# Возвращает новую длину строки
.macro rtrim_endl_body  # (buffer_address, length) -> new_length
	add a0 a0 a1  # Адрес \0
	addi a0 a0 -1  # Адрес последнего символа
	li t0 '\n'
	lb t1 (a0)
	bne t1 t0 end
		sb zero (a0)
		addi a1 a1 -1
	end:
	mv a0 a1
.end_macro
func(_rtrim_endl, rtrim_endl_body)

# Функция ввода строки
# Производит системный вызов №8, убирает лишний символ \n с конца строки
# Возвращает длину строки (без учёта \0)
# В решении не используется, так как было заменено на input_dialog
# Но удалять не стал - оставил на будущее :)
.macro input_body  # (buffer, buffer_size) -> length
	save(s0)
	li a7 8
	ecall  # Все аргументы уже на месте
	mv s0 a0
	jal _strlen  # Все аргументы уже на месте
	
	# Размещаем аргументы для rtrim_endl
	mv a1 a0
	mv a0 s0
	jal _rtrim_endl  # Возвращает то, что должен вернуть input
	restore(s0)
.end_macro 
gfunc(_input, input_body)

# То же, что и input, но через Dialog
.macro input_dialog_body
	save(s0)
	mv t0 a1
	li a7 54
	ecall  # Все аргументы уже на месте
	mv s0 t0
	mv a0 t0
	jal _strlen  # Все аргументы уже на месте
	
	# Размещаем аргументы для rtrim_endl
	mv a1 a0
	mv a0 s0
	jal _rtrim_endl  # Возвращает то, что должен вернуть input
	restore(s0)
.end_macro
gfunc(_input_dialog, input_dialog_body)

# Функция для открывания файла
.macro open_body  # (filename, mode) -> (descriptor, length)
	li a7 1024  # open
	ecall
	check_error(a0)
.end_macro
gfunc(_open, open_body)

# Доходит до конца файла, считывая его длину
# Возвращает длину содержимого файла
.macro shift_body  # (desc) -> length
mv t0 a0  # в t0 - дескриптор
	li a7 62  # LSeek - меняем позицию в потоке
	li a1 0  # offset - 0...
	li a2 2  # ...с конца файла (т.е. читаем до конца)
	ecall
	check_error(a0)
.end_macro
gfunc(_shift, shift_body)

# Читает символы из файла и выводит их в буфер, такие что:
# 1. В файле они идут подряд
# 2. Их заданное количество (арг. block_length)
# 3. Они заканчиваются позицией, которая на момент вызова функции была текущей
# По итогу позиция в файле будет сдвинута на block_length от изначальной позиции 
# Таким образом, если начальная позиция в файле - конец, то вызывая эту функцию несколько раз, файл можно читать "с конца"
# Например, если содержимое файла:
# 	onetwothree
# Считав сначала блок длины 2, а потом 3 блока длины 3, получим:
# 	ee|thr|two|one
# Если развернуть содержимое кажого из этих блоков, получим:
# 	ee|rht|owt|eno
# А это и есть развернутая строка!
.macro read_block_body  # (desc, block_length, out)
	# Сохраним аргументы
	mv t0 a0
	mv t1 a1
	mv t2 a2
	# Сдвинемся назад
	li a7 62
	neg a1 t1
	li a2 1
	ecall
	check_error(a0)
	# Считаем символы
	li a7 63
	mv a0 t0
	mv a1 t2
	mv a2 t1
	ecall
	check_error(a0)
	# А затем снова сдвинемся назад
	li a7 62
	mv a0 t0
	neg a1 t1
	li a2 1
	ecall
	check_error(a0)
.end_macro
gfunc(_read_block, read_block_body)

# Выводит символы из буфера в файл
.macro write_body  # (desc, buf, length)
	li a7 64
	ecall
	check_error(a0)
.end_macro
gfunc(_write, write_body)
	
