# 입력 스트링을 한글자씩 입력받는다.
#

################################
# DATA 
################################
.data 0x0000

# buffer for 25 line input strings 
strs: .space 2500

# pointer for addressing each line
ptrs: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    

################################
# MACRO  
################################
# exit
.macro exit
	li   $v0,10
	syscall
.end_macro	

# print string
.macro print_str(%str)
.data
myLabel: .asciiz %str
.text
	li   $v0, 4
	la   $a0, myLabel
	syscall
.end_macro


################################
# TEXT
################################
.text 0x3000

main:
	print_str("*starting.\n")
	print_str("*input 25line strings.\n")
	
# read user input
    li   $t0, 0
    la   $s2, ptrs 

userinput.loop: 
    la   $a0, strs($t0)  # address of buffer to which to read
    li   $s1, 0
    
userinput.onebyte:    
    li   $v0, 8          # syscall for read string
    li   $a1, 2          # buffer length
    syscall              # read from fil
    
    addi $s1, $s1, 1
    beq  $s1, 100, userinput.oneline_end
    lb   $t2, ($a0)
    li   $t5, 0x0A
    addi $a0, $a0, 1
    bne  $t2, $t5, userinput.onebyte
    
userinput.oneline_end:
	sw   $t0, ($s2)
	addi $s2, $s2, 4
    add  $t0, $t0, 100
    bne  $t0, 2500, userinput.loop


                            
################################
	print_str("**********read strings**********\n")
	jal  print_strings
                        
################################
# Bubble Sorting
	li   $t7,  0
sort.loop1:
			
    li   $t5, 0
sort.loop2:
	addi $t6, $t5, 4
	lw   $a0, ptrs($t5)
	lw   $a1, ptrs($t6)
	jal  cmp_gt 
	
	beqz $v0, sort.ok
	sw   $a0, ptrs($t6) # swap
	sw   $a1, ptrs($t5) # swap
	
sort.ok:
	addi $t5, $t5, 4	
	li   $s1, 96
	sub  $s1, $s1, $t7  
	blt  $t5, $s1, sort.loop2
		
	addi $t7, $t7, 4
	blt  $t7, 100, sort.loop1
	
	
################################
	print_str("**********sorted strings**********\n")
	jal  print_strings
	
################################		
	print_str("*finished.\n")
	exit	


################################
# return 1 if $a0 > $a1
cmp_gt:
	lb   $t0, ($a0)  # load a byte from each string
	lb   $t1, ($a1)
	beq  $t0, 0x0d, cmp.gt # if only \r\n string  
	beq  $t1, 0x0d, cmp.le
	beqz $t0, cmp.le
	beqz $t1, cmp.gt
	ble  $t0, $t1, cmp.le
	bgt  $t0, $t1, cmp.gt

	addi $a0, $a0, 1  # a0 points to the next byte of str1
	addi $a1, $a1, 1
	j cmp_gt

cmp.le:
	li $v0, 0     # set return value	
	jr $ra
	
cmp.gt:
	li $v0, 1
	jr $ra


################################
# print read strings
print_strings:
	li   $t0, 0    

print.loop:
	li   $v0, 4          # print string
	lw   $a0, ptrs($t0)  # address of string to be printed
	syscall

	add  $t0, $t0, 4
	bne  $t0, 100, print.loop
	
	jr   $ra







