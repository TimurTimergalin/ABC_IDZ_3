# Макрос для удобного оперделения функций
# Определяя подпрограммы таким образом тело функции оборачивается в макрос, что делает метки локальными.
# Также это позволяет не писать пролог и эпилог в каждой функции
.macro func (%name, %body)
.text
	%name:
	# Пролог
	sw ra (sp)
	addi sp sp -4
	
	%body ()
	
	# Эпилог 
	lw ra 4(sp)
	addi sp sp 4
	ret
.end_macro

.macro gfunc(%name, %body)  # Как func, только функция помечается как глобальная
	func (%name, %body)
	.globl %name
.end_macro

.macro save (%s)  # Сохраняет значение регистра на стеке.
	sw %s (sp)
	addi sp sp -4
.end_macro

.macro fsave.d (%s)  # Сохраняет double-значение регистра на стеке
	addi sp sp -4
	fsd %s (sp)
	addi sp sp -4
.end_macro

.macro restore (%s)  # Восстананвливает значение регистра значением из стека.
	lw %s 4(sp)
	addi sp sp 4
.end_macro

.macro frestore.d (%s)  # Восстанавливает double-значение регистра значением из стека. 
	fld %s 4(sp)
	addi sp sp 8
.end_macro
