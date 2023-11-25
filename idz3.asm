.include "convenience.inc"
.include "io.inc"
.include "reverse.inc"

.eqv BUFFER_SIZE 512
.data
	buffer: .space BUFFER_SIZE  # ����� ������������ ����� ��� ����� - � ��� ����� �������� ������, � ��� ���������� ������ �� �����
		.byte 0  # ������� ����� ����� ��� ������
	sinp: .asciz "������� �������� �������� �����: "
	sout: .asciz "������� �������� ��������� �����: "
	sprint: .asciz "������� �� ����� � �������? - "
	
.globl main
.text
main:
	input_dialog(sinp, buffer, BUFFER_SIZE)
	openr(buffer)
	mv s0 a0  # ������� ����
	shift (s0)
	mv s1 a0  # ����� �������� �����
	
	input_dialog(sout, buffer, BUFFER_SIZE)
	openw(buffer)
	mv s2 a0  # �������� ����
	
	input_dialog(sprint, buffer, 2)  # ���� ���� - �� Y/N, ������ - �� \0
	li t0 'Y'
	la t2 buffer
	lb t1 (t2)
	sub t0 t0 t1
	seqz s3 t0  # �������� � ������� ���������, ��� ���
	nl()
	
	reverse (s0, s1, s2, buffer, BUFFER_SIZE, s3)
	exit()
