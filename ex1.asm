################################
# DATA 
################################
.data 0x0000

# buffer for 25 line input strings 
strs: .space 2500

# pointer for addressing each line
ptrs: .word    0,  100,  200,  300,  400, 
			 500,  600,  700,  800,  900,
			1000, 1100, 1200, 1300, 1400,
			1500, 1600, 1700, 1800, 1900, 
			2000, 2100, 2200, 2300, 2400

newline: .asciiz "\n"

fname_in:  .asciiz "ex1in1.txt"
fname_out: .asciiz "ex1out1.txt"

################################
# MACRO  
################################
# exit
.macro exit
	li   $v0,10
	syscall
.end_macro	

# print int
.macro print_int(%x)
	li   $v0, 1
	add  $a0, $zero, %x
	syscall
	
	li   $v0, 4
	la   $a0, newline
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

################################
# read input file data to memory array
# input file open 
	li   $v0, 13         # system call for open file
	la   $a0, fname_in   # set file name
	li   $a1, 0          # Open for reading
	li   $a2, 0
	syscall              # open a file (file descriptor returned in $v0)
	move $s6, $v0        # save the file descriptor 		

            
#read from file
	li   $t0, 0

read.loop:	
	lw   $a1, ptrs($t0)  # address of buffer to which to read
    
read.onebyte:    
	li   $v0, 14         # system call for read from file
	move $a0, $s6        # file descriptor 
	li   $a2, 1          # buffer length
	syscall              # read from file
	
	lb   $t2, ($a1)
	addi $a1, $a1, 1
	li   $t5, 0x0A
	bne	 $t2, $t5, read.onebyte    
    
    
	add  $t0, $t0, 4
	bne  $t0, 100, read.loop
    
       
# Close input file 
    li   $v0, 16         # system call for close file
    move $a0, $s6        # file descriptor to close
    syscall              # close file
    
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
# write sorted data to file	
# Open (for writing) a file
	li   $v0, 13       # system call for open file
	la   $a0, fname_out# output file name
	li   $a1, 1        # Open for writing (flags are 0: read, 1: w`rite)
	li   $a2, 0        # mode is ignored
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor 
	
# Write to file
	li   $t0, 0

write.loop:	
	lw   $a1, ptrs($t0)# address of buffer to which to write

write.onebyte:	
	lb   $t2, ($a1)
	beqz $t2, write.oneline_end
	

	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	li   $a2, 1        # hardcoded buffer length
	syscall            # write to file
	
	addi $a1, $a1, 1
	j    write.onebyte
	
write.oneline_end:                
	add  $t0, $t0, 4
	bne  $t0, 100, write.loop

	
# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file
		
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







