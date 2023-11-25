.include "convenience.inc"
.include "io.inc"
.include "reverse.inc"

.eqv BUFFER_SIZE 512
.data
	buffer: .space BUFFER_SIZE  # Будем использовать буфер для всего - и для ввода названий файлов, и для считывания данных из файла
		.byte 0  # Отделим буфер нулем для вывода
	sinp: .asciz "Введите название входного файла: "
	sout: .asciz "Введите название выходного файла: "
	sprint: .asciz "Вывести ли ответ в консоль? - "
	
.globl main
.text
main:
	input_dialog(sinp, buffer, BUFFER_SIZE)
	openr(buffer)
	mv s0 a0  # Входной файл
	shift (s0)
	mv s1 a0  # Длина входного файла
	
	input_dialog(sout, buffer, BUFFER_SIZE)
	openw(buffer)
	mv s2 a0  # Выходной файл
	
	input_dialog(sprint, buffer, 2)  # один байт - на Y/N, второй - на \0
	li t0 'Y'
	la t2 buffer
	lb t1 (t2)
	sub t0 t0 t1
	seqz s3 t0  # Печатать в консоль результат, или нет
	nl()
	
	reverse (s0, s1, s2, buffer, BUFFER_SIZE, s3)
	exit()
