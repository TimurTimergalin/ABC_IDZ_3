.include "convenience.inc"
.include "mfunc.inc"

.data
	sioerr: .asciz "IO error\n"
.text


# ������ �� �������� ������ io
# ������ syscall, ���������� � �������, ���������� -1, ���� ��������� ������
# ���� ������ ��������� �������� ����������� �������� �� ��������� -1
# � ������ ���������� ��������� ��������� �� ������, � ��������� �������� �����������
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

# ������� ���������� ����� ������ (��� ����� \0)
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

# �������, ��������� ������ \n � ����� ������, ���� �� ����
# ���������� ����� ����� ������
.macro rtrim_endl_body  # (buffer_address, length) -> new_length
	add a0 a0 a1  # ����� \0
	addi a0 a0 -1  # ����� ���������� �������
	li t0 '\n'
	lb t1 (a0)
	bne t1 t0 end
		sb zero (a0)
		addi a1 a1 -1
	end:
	mv a0 a1
.end_macro
func(_rtrim_endl, rtrim_endl_body)

# ������� ����� ������
# ���������� ��������� ����� �8, ������� ������ ������ \n � ����� ������
# ���������� ����� ������ (��� ����� \0)
# � ������� �� ������������, ��� ��� ���� �������� �� input_dialog
# �� ������� �� ���� - ������� �� ������� :)
.macro input_body  # (buffer, buffer_size) -> length
	save(s0)
	li a7 8
	ecall  # ��� ��������� ��� �� �����
	mv s0 a0
	jal _strlen  # ��� ��������� ��� �� �����
	
	# ��������� ��������� ��� rtrim_endl
	mv a1 a0
	mv a0 s0
	jal _rtrim_endl  # ���������� ��, ��� ������ ������� input
	restore(s0)
.end_macro 
gfunc(_input, input_body)

# �� ��, ��� � input, �� ����� Dialog
.macro input_dialog_body
	save(s0)
	mv t0 a1
	li a7 54
	ecall  # ��� ��������� ��� �� �����
	mv s0 t0
	mv a0 t0
	jal _strlen  # ��� ��������� ��� �� �����
	
	# ��������� ��������� ��� rtrim_endl
	mv a1 a0
	mv a0 s0
	jal _rtrim_endl  # ���������� ��, ��� ������ ������� input
	restore(s0)
.end_macro
gfunc(_input_dialog, input_dialog_body)

# ������� ��� ���������� �����
.macro open_body  # (filename, mode) -> (descriptor, length)
	li a7 1024  # open
	ecall
	check_error(a0)
.end_macro
gfunc(_open, open_body)

# ������� �� ����� �����, �������� ��� �����
# ���������� ����� ����������� �����
.macro shift_body  # (desc) -> length
mv t0 a0  # � t0 - ����������
	li a7 62  # LSeek - ������ ������� � ������
	li a1 0  # offset - 0...
	li a2 2  # ...� ����� ����� (�.�. ������ �� �����)
	ecall
	check_error(a0)
.end_macro
gfunc(_shift, shift_body)

# ������ ������� �� ����� � ������� �� � �����, ����� ���:
# 1. � ����� ��� ���� ������
# 2. �� �������� ���������� (���. block_length)
# 3. ��� ������������� ��������, ������� �� ������ ������ ������� ���� �������
# �� ����� ������� � ����� ����� �������� �� block_length �� ����������� ������� 
# ����� �������, ���� ��������� ������� � ����� - �����, �� ������� ��� ������� ��������� ���, ���� ����� ������ "� �����"
# ��������, ���� ���������� �����:
# 	onetwothree
# ������ ������� ���� ����� 2, � ����� 3 ����� ����� 3, �������:
# 	ee|thr|two|one
# ���� ���������� ���������� ������ �� ���� ������, �������:
# 	ee|rht|owt|eno
# � ��� � ���� ����������� ������!
.macro read_block_body  # (desc, block_length, out)
	# �������� ���������
	mv t0 a0
	mv t1 a1
	mv t2 a2
	# ��������� �����
	li a7 62
	neg a1 t1
	li a2 1
	ecall
	check_error(a0)
	# ������� �������
	li a7 63
	mv a0 t0
	mv a1 t2
	mv a2 t1
	ecall
	check_error(a0)
	# � ����� ����� ��������� �����
	li a7 62
	mv a0 t0
	neg a1 t1
	li a2 1
	ecall
	check_error(a0)
.end_macro
gfunc(_read_block, read_block_body)

# ������� ������� �� ������ � ����
.macro write_body  # (desc, buf, length)
	li a7 64
	ecall
	check_error(a0)
.end_macro
gfunc(_write, write_body)
	
