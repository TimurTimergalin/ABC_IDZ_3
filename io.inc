.macro input (%buffer_address, %buffer_size)
	la a0 %buffer_address
	li a1 %buffer_size
	jal _input
.end_macro

.macro input_dialog (%message, %buffer, %buffer_size)
	la a0 %message
	la a1 %buffer
	li a2 %buffer_size
	jal _input_dialog
.end_macro

.macro open (%filename, %mode)
	la a0 %filename
	li a1 %mode
	jal _open
.end_macro

.macro openr (%filename)
	open (%filename, 0)
.end_macro

.macro openw (%filename)
	open (%filename, 1)
.end_macro

.macro shift (%desc)
	mv a0 %desc
	jal _shift
.end_macro

.macro read_block (%desc, %block_length, %out)
	mv a0 %desc
	mv a1 %block_length
	mv a2 %out
	jal _read_block
.end_macro

.macro write (%desc, %buf, %length)
	mv a0 %desc
	mv a1 %buf
	mv a2 %length
	jal _write
.end_macro
