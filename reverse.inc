.macro reverse (%desc_in, %length, %desc_out, %buf, %buf_size, %print)
	mv a0 %desc_in
	mv a1 %length
	mv a2 %desc_out
	la a3 %buf
	li a4 %buf_size
	mv a5 %print
	jal _reverse
.end_macro
