######################################################################
# CSCB58 Summer 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Malhar Pandya, 1005893008, pandyam8
# Student: Yara Radwan, 1006280748, radwanya
#
# Bitmap Display Configuration:
# -Unit width in pixels: 8 (update this as needed)
# -Unit height in pixels: 8 (update this as needed)
# -Display width in pixels: 256 (update this as needed)
# -Display height in pixels: 512 (update this as needed)
# -Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# -Milestone 1/2/3 (choose the one that applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# -(insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# -yes / no/ yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# -(write here, if any)
######################################################################

# DECLARING CONSTANTS
.eqv KEYBOARD_ADDRESS 0xffff0000

.eqv RESET_ADDRESS 0x10008000

# Movement Related
.eqv BITMAP_W_LIMIT 0x10006334
.eqv BITMAP_S_LIMIT 0x10007fcc
.eqv BITMAP_A_REMAINDER 76
.eqv BITMAP_D_REMAINDER 52

.eqv BOOSTER_BITMAP_W_LIMIT 0x100063b0
.eqv BOOSTER_BITMAP_S_LIMIT 0x10007f50
.eqv BOOSTER_BITMAP_A_REMAINDER 80
.eqv BOOSTER_BITMAP_D_REMAINDER 48

.eqv WIDTH 128

.eqv START_REFRESH_RATE 40

# Colors
.eqv SHIP_COLOUR 0x7daffa # light blue
.eqv BLACK 0x000000 # for redrawing
.eqv WHITE 0xffffff # for background

.data
	SHIP_ADDRESS: .word 0x10008000
	OBSTACLE_ADDRESSES: .word 0:3
	BOOSTER_FLAG: .word 0
	LAST_KEYBOARD_INPUT: .word 0

.text

.globl main
	
	
############################# INITIALIZE #############################	
	
SETUP:
	# draw the ship initially and jump to main
	la $t0, SHIP_ADDRESS
	lw, $t0, 0($t0)
	li $t1, SHIP_COLOUR
	jal DRAW_SHIP_INIT
	j main
		
# acts as main refresh loop
main:
	# generate delay
	li $v0, 32
	li $a0, 40
	syscall
	
	# check for keyboard input and branch accordingly
	li $t0, KEYBOARD_ADDRESS
	lw $t1, 0($t0)
	beq $t1, 1, KEYPRESS
	j NO_KEYPRESS
	
######################################################################



########################## DRAWING SECTION ##########################

# used to draw the whole ship initially
DRAW_SHIP_INIT:
	sw $t1, 7484($t0)
	sw $t1, 7488($t0)
	
	sw $t1, 7608($t0)
	sw $t1, 7612($t0)
	sw $t1, 7616($t0)
	sw $t1, 7620($t0)

	sw $t1, 7732($t0)
	sw $t1, 7736($t0)
	sw $t1, 7740($t0)
	sw $t1, 7744($t0)
	sw $t1, 7748($t0)
	sw $t1, 7752($t0)
	
	sw $t1, 7860($t0)
	sw $t1, 7864($t0)
	sw $t1, 7868($t0)
	sw $t1, 7872($t0)
	sw $t1, 7876($t0)
	sw $t1, 7880($t0)
	
	sw $t1, 7988($t0)
	sw $t1, 7992($t0)
	sw $t1, 8004($t0)
	sw $t1, 8008($t0)
	
	sw $t1, 8116($t0)
	sw $t1, 8136($t0)
	
	jr $ra

# draws ship vertical border
UPDATE_SHIP_WS_HELPER:
	sw $t1, 7868($t0)
	sw $t1, 7872($t0)
	
	sw $t1, 7992($t0)
	sw $t1, 8004($t0)
	
	sw $t1, 8116($t0)
	sw $t1, 8136($t0)
	
	jr $ra

# draws left border
UPDATE_SHIP_LEFT_HELPER:
	sw $t1, 7484($t0)
	
	sw $t1, 7608($t0)

	sw $t1, 7732($t0)
	
	sw $t1, 7860($t0)
	
	sw $t1, 7988($t0)
	sw $t1, 8004($t0)
	
	sw $t1, 8116($t0)
	sw $t1, 8136($t0)
	
	jr $ra
	
# draws left border
BOOSTER_UPDATE_SHIP_LEFT_HELPER:
	sw $t1, 7484($t0)
	sw $t1, 7488($t0)
	
	sw $t1, 7608($t0)
	sw $t1, 7612($t0)

	sw $t1, 7732($t0)
	sw $t1, 7736($t0)
	
	sw $t1, 7860($t0)
	sw $t1, 7864($t0)
	
	sw $t1, 7988($t0)
	sw $t1, 7992($t0)
	sw $t1, 8004($t0)
	sw $t1, 8008($t0)
	
	sw $t1, 8116($t0)
	sw $t1, 8136($t0)
	
	jr $ra

# draws right border	
UPDATE_SHIP_RIGHT_HELPER:
	sw $t1, 7488($t0)
	
	sw $t1, 7620($t0)

	sw $t1, 7752($t0)

	sw $t1, 7880($t0)
	
	sw $t1, 7992($t0)
	sw $t1, 8008($t0)
	
	sw $t1, 8116($t0)
	sw $t1, 8136($t0)
	
	jr $ra
	
# draws right border	
BOOSTER_UPDATE_SHIP_RIGHT_HELPER:
	sw $t1, 7484($t0)
	sw $t1, 7488($t0)

	sw $t1, 7616($t0)
	sw $t1, 7620($t0)

	sw $t1, 7748($t0)
	sw $t1, 7752($t0)

	sw $t1, 7876($t0)
	sw $t1, 7880($t0)
	
	sw $t1, 7988($t0)
	sw $t1, 7992($t0)
	sw $t1, 8004($t0)
	sw $t1, 8008($t0)
	
	sw $t1, 8116($t0)
	sw $t1, 8136($t0)
	
	jr $ra

######################################################################



############################# KEY INPUT ##############################

KEYPRESS:
	# check if any valid key was pressed and branch accordingly
	lw $t0, 4($t0)
	
	# update last key press
	la $t1, LAST_KEYBOARD_INPUT
	sw $t0, 0($t1)
	beq $t0, 0x77, W_KEYPRESS # ASCII code of 'w' is 0x77
	beq $t0, 0x61, A_KEYPRESS # ASCII code of 'a' is 0x61
	beq $t0, 0x73, S_KEYPRESS # ASCII code of 's' is 0x73
	beq $t0, 0x64, D_KEYPRESS # ASCII code of 'd' is 0x64
	beq $t0, 0x70, P_KEYPRESS # ASCII code of 'p' is 0x70
	j main

NO_KEYPRESS:
	la $t0, LAST_KEYBOARD_INPUT
	lw $t0, 0($t0)
	beq $t0, 0x77, W_KEYPRESS # ASCII code of 'w' is 0x77
	beq $t0, 0x61, A_KEYPRESS # ASCII code of 'a' is 0x61
	beq $t0, 0x73, S_KEYPRESS # ASCII code of 's' is 0x73
	beq $t0, 0x64, D_KEYPRESS # ASCII code of 'd' is 0x64
	j main
	
W_KEYPRESS:
	# get status of powerup
	la $t0, BOOSTER_FLAG
	lw $t0, 0($t0)
	bgtz $t0 BOOSTER_W_KEYPRESS
	
	# Check if upward move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	bgt $t0, BITMAP_W_LIMIT UPDATE_SHIP_W
	j main
	
BOOSTER_W_KEYPRESS:
	# Check if upward move is possible for boosted mode
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	bgt $t0, BOOSTER_BITMAP_W_LIMIT BOOSTER_UPDATE_SHIP_W
	j main

UPDATE_SHIP_W:
	#turn bottom border black
	li $t1, BLACK
	
	jal UPDATE_SHIP_WS_HELPER
	
	#add border above current border
	subi $t0, $t0, 512
	
	li $t1, SHIP_COLOUR
	
	jal UPDATE_SHIP_WS_HELPER

	addi $t0, $t0, 384
	
	#update position in memory
	la $t1, SHIP_ADDRESS
	sw $t0, 0($t1)
	
	j main
	
BOOSTER_UPDATE_SHIP_W:
	#turn bottom border black
	li $t1, BLACK
	
	jal UPDATE_SHIP_WS_HELPER
	
	subi $t0, $t0, 128
	
	jal UPDATE_SHIP_WS_HELPER
	
	#add border above current border
	subi $t0, $t0, 384
	
	li $t1, SHIP_COLOUR
	
	jal UPDATE_SHIP_WS_HELPER
	
	subi $t0, $t0, 128
	
	jal UPDATE_SHIP_WS_HELPER
	
	addi $t0, $t0, 384
	
	#update position in memory
	la $t1, SHIP_ADDRESS
	sw $t0, 0($t1)
	
	j main
	
S_KEYPRESS:
	# get status of powerup
	la $t0, BOOSTER_FLAG
	lw $t0, 0($t0)
	bgtz $t0 BOOSTER_S_KEYPRESS
	
	# Check if downward move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	blt $t0, BITMAP_S_LIMIT UPDATE_SHIP_S
	j main
	
BOOSTER_S_KEYPRESS:
	# Check if downward move is possible for boosted mode
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	blt $t0, BOOSTER_BITMAP_S_LIMIT BOOSTER_UPDATE_SHIP_S
	j main

UPDATE_SHIP_S:
	#turn top border black
	subi $t0, $t0, 384
	
	li $t1, BLACK
	
	jal UPDATE_SHIP_WS_HELPER
	
	#add border below current border
	addi $t0, $t0, 512
	
	li $t1, SHIP_COLOUR
	
	jal UPDATE_SHIP_WS_HELPER
	
	#update position in memory
	la $t1, SHIP_ADDRESS
	sw $t0, 0($t1)
	
	j main
	
BOOSTER_UPDATE_SHIP_S:
	#turn top border black
	subi $t0, $t0, 256
	
	li $t1, BLACK
	
	jal UPDATE_SHIP_WS_HELPER
	
	subi $t0, $t0, 128
	
	jal UPDATE_SHIP_WS_HELPER
	
	#add border above below border
	addi $t0, $t0, 512
	
	li $t1, SHIP_COLOUR
	
	jal UPDATE_SHIP_WS_HELPER
	
	addi $t0, $t0, 128
	
	jal UPDATE_SHIP_WS_HELPER
	
	#update position in memory
	la $t1, SHIP_ADDRESS
	sw $t0, 0($t1)
	
	j main	
	
A_KEYPRESS:
	# get status of powerup
	la $t0, BOOSTER_FLAG
	lw $t0, 0($t0)
	bgtz $t0 BOOSTER_A_KEYPRESS
	
	# check if left move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, WIDTH
	div $t0, $t1
	mfhi $t1
	li $t2, BITMAP_A_REMAINDER
	bne $t1, $t2, UPDATE_SHIP_A
	j main
	
BOOSTER_A_KEYPRESS:
	#check if left move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, WIDTH
	div $t0, $t1
	mfhi $t1
	li $t2, BOOSTER_BITMAP_A_REMAINDER
	bne $t1, $t2, BOOSTER_UPDATE_SHIP_A
	j main

UPDATE_SHIP_A:
	#turn right border black
	li $t1, BLACK
	jal UPDATE_SHIP_RIGHT_HELPER
	
	#add left border
	subi $t0, $t0, 4
	
	li $t1, SHIP_COLOUR
	jal UPDATE_SHIP_LEFT_HELPER
	
	#update ship address
	la $t1, SHIP_ADDRESS
	sw, $t0, 0($t1)
	
	j main
	
BOOSTER_UPDATE_SHIP_A:

	#turn right border black
	li $t1, BLACK
	jal BOOSTER_UPDATE_SHIP_RIGHT_HELPER
	
	#add left border
	subi $t0, $t0, 8
	
	li $t1, SHIP_COLOUR
	jal BOOSTER_UPDATE_SHIP_LEFT_HELPER
	
	#update ship address
	la $t1, SHIP_ADDRESS
	sw, $t0, 0($t1)
	
	j main
	
D_KEYPRESS:
	# get status of powerup
	la $t0, BOOSTER_FLAG
	lw $t0, 0($t0)
	bgtz $t0 BOOSTER_D_KEYPRESS
	
	# check if right move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, WIDTH
	div $t0, $t1
	mfhi $t1
	li $t2, BITMAP_D_REMAINDER
	bne $t1, $t2, UPDATE_SHIP_D
	j main
	
BOOSTER_D_KEYPRESS:
	# check if right move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, WIDTH
	div $t0, $t1
	mfhi $t1
	li $t2, BOOSTER_BITMAP_D_REMAINDER
	bne $t1, $t2, BOOSTER_UPDATE_SHIP_D
	j main
	
UPDATE_SHIP_D:
	#turn left border black
	li $t1, BLACK
	jal UPDATE_SHIP_LEFT_HELPER
	
	#add right border
	addi $t0, $t0, 4
	
	li $t1, SHIP_COLOUR
	jal UPDATE_SHIP_RIGHT_HELPER
	
	#update ship address
	la $t1, SHIP_ADDRESS
	sw, $t0, 0($t1)
	
	j main
	
BOOSTER_UPDATE_SHIP_D:
	#turn left border black
	li $t1, BLACK
	jal BOOSTER_UPDATE_SHIP_LEFT_HELPER
	
	#add right border
	addi $t0, $t0, 8
	
	li $t1, SHIP_COLOUR
	jal BOOSTER_UPDATE_SHIP_RIGHT_HELPER
	
	#update ship address
	la $t1, SHIP_ADDRESS
	sw, $t0, 0($t1)
	
	j main

P_KEYPRESS:
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	#erase ship
	li $t1, BLACK
	jal DRAW_SHIP_INIT
	
	li $t0, RESET_ADDRESS
	
	#draw ship at init point
	li $t1, SHIP_COLOUR
	jal DRAW_SHIP_INIT
	
	#update ship address
	la $t1, SHIP_ADDRESS
	sw $t0, 0($t1)
	
	#update keyboard stack
	la $t0, LAST_KEYBOARD_INPUT
	sw $zero, 0($t0)
	
	j main
	
######################################################################
