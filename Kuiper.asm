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
# -Milestone 1/2/3 (choose the one thatapplies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fillin the feature, if any)# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# -(insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# -yes / no/ yes, and please share this project githublink as well!
#
# Any additional information that the TA needs to know:
# -(write here, if any)
######################################################################

# DECLARING CONSTANTS

#Addresses
.eqv KEYBOARD_ADDRESS 0xffff0000
.eqv RESET_ADDRESS 0x10009d3c
.eqv BASE_ADDRESS 0x10008000
.eqv TOP_ADDRESS 0x10007d00
.eqv BOTTOM_ADDRESS 0x1000A080
# Movement Related
.eqv BITMAP_W_LIMIT 0x10008070
.eqv BITMAP_S_LIMIT 0x10009d08
.eqv BITMAP_A_REMAINDER 8
.eqv BITMAP_D_REMAINDER 112

.eqv BOOSTER_BITMAP_W_LIMIT 0x100080ec
.eqv BOOSTER_BITMAP_S_LIMIT 0x10009e8c
.eqv BOOSTER_BITMAP_A_REMAINDER 12
.eqv BOOSTER_BITMAP_D_REMAINDER 108

.eqv ROW 128
.eqv COLUMN 4

#Randomness
.eqv X_RANDOMNESS_THRESHOLD 30
.eqv Y_RANDOMNESS_THRESHOLD 128

#Game constants
.eqv INIT_REFRESH_RATE 50
.eqv ASTEROID_COUNT 10 #changeable
.eqv ASTEROID_TYPE_COUNT 2

# Colours
.eqv SHIP_COLOUR 0x7daffa # light blue
.eqv BLACK 0x000000 # for redrawing
.eqv WHITE 0xffffff # for background

# Basic Asteroid Colours
.eqv LIGHT_GRAY, 0x9e9e9e
.eqv GRAY, 0x757575

# Complex Asteroid Colours
.eqv LIGHT_BROWN, 0xbcaaa4
.eqv BROWN, 0x8d6e63

# Colours for 'GAME OVER' screen
.eqv YELLOW 0xfdffbc
.eqv PEACH 0xffeebb 
.eqv SALMON 0xffdcb8
.eqv PINK 0xffc1b6

.data
	REFRESH_RATE: INIT_REFRESH_RATE
	SHIP_ADDRESS: .word RESET_ADDRESS
	ASTEROIDS: .word 0:ASTEROID_COUNT
    	ASTEROID_TYPES: .word 0:ASTEROID_COUNT
   	ASTEROID_COLORS: .word 0:2
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
	
    	li $t9, 0 # counter
    	la $t8, ASTEROIDS
    	la $t7, ASTEROID_TYPES
	j GENERATE_ASTEROIDS
		
# acts as main refresh loop
main:
	# generate delay
	la $t1, REFRESH_RATE
	lw $t1, 0($t1)
	li $v0, 32
	move $a0, $t1
	syscall
    
    	li $t9, 0 # counter
    	la $t8, ASTEROIDS
    	la $t7, ASTEROID_TYPES
	j UPDATE_ASTEROIDS

    
CHECK_INPUT:
	# check for keyboard input and branch accordingly
	li $t0, KEYBOARD_ADDRESS
	lw $t1, 0($t0)
	beq $t1, 1, KEYPRESS
	j NO_KEYPRESS
	
######################################################################



########################## DRAWING SECTION ##########################

# used to draw the whole ship initially
DRAW_SHIP_INIT:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)

	sw $t1, 248($t0)
	sw $t1, 252($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	
	sw $t1, 376($t0)
	sw $t1, 380($t0)
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	sw $t1, 392($t0)
	sw $t1, 396($t0)
	
	sw $t1, 504($t0)
	sw $t1, 508($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	
	sw $t1, 632($t0)
	sw $t1, 652($t0)
	
	jr $ra
  
# used to draw basic asteroid (plus/cross design, duo-coloured)
DRAW_BASIC_ASTEROID:
	sw $t1, 0($t0)
    	sw $t2, -4($t0)
    	sw $t2, 4($t0)
    	sw $t2, -128($t0)
    	sw $t2, 128($t0)
    
    	jr $ra
    
# used to draw larger, more complex asteroid (diagonally orientated, single coloured)
DRAW_COMPLEX_ASTEROID:
    	sw $t1, 0($t0)
    	sw $t2, -4($t0)
    	sw $t2, 4($t0)
    	sw $t2, -128($t0)
    	sw $t1, -132($t0)
    	sw $t2, 128($t0)
    	sw $t1, 132($t0)
    
    	jr $ra

# draws ship vertical border
UPDATE_SHIP_WS_HELPER:
	sw $t1, 384($t0)
	sw $t1, 388($t0)
	
	sw $t1, 508($t0)
	sw $t1, 520($t0)
	
	sw $t1, 632($t0)
	sw $t1, 652($t0)
	
	jr $ra

# draws left border
UPDATE_SHIP_LEFT_HELPER:
	sw $t1, 0($t0)
	
	sw $t1, 124($t0)

	sw $t1, 248($t0)
	
	sw $t1, 376($t0)
	
	sw $t1, 504($t0)
	sw $t1, 520($t0)
	
	sw $t1, 632($t0)
	sw $t1, 652($t0)
	
	jr $ra
	
# draws left border
BOOSTER_UPDATE_SHIP_LEFT_HELPER:
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	sw $t1, 248($t0)
	sw $t1, 252($t0)
	
	sw $t1, 376($t0)
	sw $t1, 380($t0)
	
	sw $t1, 504($t0)
	sw $t1, 508($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	
	sw $t1, 632($t0)
	sw $t1, 652($t0)
	
	jr $ra

# draws right border	
UPDATE_SHIP_RIGHT_HELPER:
	sw $t1, 4($t0)
	
	sw $t1, 136($t0)

	sw $t1, 268($t0)

	sw $t1, 396($t0)
	
	sw $t1, 508($t0)
	sw $t1, 524($t0)
	
	sw $t1, 632($t0)
	sw $t1, 652($t0)
	
	jr $ra
	
# draws right border	
BOOSTER_UPDATE_SHIP_RIGHT_HELPER:
	sw $t1, 0($t0)
	sw $t1, 4($t0)

	sw $t1, 132($t0)
	sw $t1, 136($t0)

	sw $t1, 264($t0)
	sw $t1, 268($t0)

	sw $t1, 392($t0)
	sw $t1, 396($t0)
	
	sw $t1, 504($t0)
	sw $t1, 508($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	
	sw $t1, 632($t0)
	sw $t1, 652($t0)
	
	jr $ra

######################################################################



############################# ASTEROIDS ##############################

GENERATE_ASTEROIDS:
	beq $t9, ASTEROID_COUNT, main
    	li $t0, BASE_ADDRESS
    	
    	jal GENERATE_RANDOMNESS
    
    	# update address and type in memory
    	sw $t0, 0($t8)
    	sw $t6, 0($t7)
    
    	# loop increment
    	addi $t7, $t7, 4
    	addi $t8, $t8, 4

	addi $t9, $t9, 1
	
	j GENERATE_ASTEROIDS
	
GENERATE_RANDOMNESS:
	# generate x_axis randomness
    	li $v0, 42
	li $a0, 0
	li $a1, X_RANDOMNESS_THRESHOLD
    	syscall
    	move $t6, $a0
    	addi $t6, $t6, 1
    
    	# update asteroid address horizontal
    	li $t5, COLUMN
    	mult $t6, $t5
    	mflo $t6
    	add $t0, $t0, $t6
    
    	# generate y_axis randomness
	li $v0, 42
	li $a0, 0
	li $a1, Y_RANDOMNESS_THRESHOLD
    	syscall
    	move $t6, $a0
    	addi $t6, $t6, 1 # fixed vertical offset
    
    	# update asteroid address vertical
    	li $t5, ROW
    	mult $t6, $t5
    	mflo $t6
    	sub $t0, $t0, $t6
    	
    	# generate random asteroid type
    	li $v0, 42
    	li $a0, 0
    	li $a1, ASTEROID_TYPE_COUNT
    	syscall
    	move $t6, $a0
    	subi $t6, $t6, 1
    	
    	jr $ra

UPDATE_ASTEROIDS:

	beq $t9, ASTEROID_COUNT, CHECK_INPUT
    	lw $t0, 0($t8)
    	
    	#check if asteroid above the bitmap
    	li $t6, TOP_ADDRESS
    	blt $t0, $t6 UPDATE_ASTEROID_DRAWLESS
    	
    	#check if asteroid below the bitmap
    	li $t6, BOTTOM_ADDRESS
    	bgt $t0, $t6, LOOP_ASTEROID

    	lw $t6, 0($t7)
       	
       	bltz $t6, UPDATE_BASIC_ASTEROID
    	bgez $t6, UPDATE_COMPLEX_ASTEROID

UPDATE_ASTEROID_DRAWLESS:
	addi $t0, $t0, ROW
	addi $t0, $t0, ROW #optional
	
	# update address in memory
    	sw $t0, 0($t8)
    
	# loop increment
    	addi $t7, $t7, 4
    	addi $t8 $t8, 4

	addi $t9, $t9, 1
	
	j UPDATE_ASTEROIDS

LOOP_ASTEROID:
	li $t0, BASE_ADDRESS
	jal GENERATE_RANDOMNESS
       	
       	sw $t6, 0($t7)
       	
       	bltz $t6, UPDATE_BASIC_ASTEROID
    	bgez $t6, UPDATE_COMPLEX_ASTEROID

UPDATE_BASIC_ASTEROID:
	li $t1, BLACK
    	li $t2, BLACK
    	jal DRAW_BASIC_ASTEROID
    	
    	addi $t0, $t0, ROW
    	addi $t0, $t0, ROW #optional
    	
    	li $t1, GRAY
    	li $t2, LIGHT_GRAY
    	jal DRAW_BASIC_ASTEROID
    
	# update address in memory
    	sw $t0, 0($t8)
    
	# loop increment
    	addi $t7, $t7, 4
    	addi $t8 $t8, 4

	addi $t9, $t9, 1
	
	j UPDATE_ASTEROIDS

UPDATE_COMPLEX_ASTEROID:
    	li $t1, BLACK
    	li $t2, BLACK
    	jal DRAW_COMPLEX_ASTEROID
    	
    	addi $t0, $t0, ROW
    	addi $t0, $t0, ROW #optional
    	
    	li $t1, BROWN
    	li $t2, LIGHT_BROWN
    	jal DRAW_COMPLEX_ASTEROID

	# update address in memory
    	sw $t0, 0($t8)
    
	# loop increment
    	addi $t7, $t7, 4
    	addi $t8 $t8, 4

	addi $t9, $t9, 1
	
	j UPDATE_ASTEROIDS


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
	# turn bottom border black
	li $t1, BLACK
	
	jal UPDATE_SHIP_WS_HELPER
	
	subi $t0, $t0, ROW
	
	jal UPDATE_SHIP_WS_HELPER
	
	#add border above current border
	subi $t0, $t0, 384
	
	li $t1, SHIP_COLOUR
	
	jal UPDATE_SHIP_WS_HELPER
	
	subi $t0, $t0, ROW
	
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
	
	subi $t0, $t0, ROW
	
	jal UPDATE_SHIP_WS_HELPER
	
	#add border above below border
	addi $t0, $t0, 512
	
	li $t1, SHIP_COLOUR
	
	jal UPDATE_SHIP_WS_HELPER
	
	addi $t0, $t0, ROW
	
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
	
	li $t1, ROW
	div $t0, $t1
	mfhi $t1
	li $t2, BITMAP_A_REMAINDER
	bne $t1, $t2, UPDATE_SHIP_A
	j main
	
BOOSTER_A_KEYPRESS:
	#check if left move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, ROW
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
	
	li $t1, ROW
	div $t0, $t1
	mfhi $t1
	li $t2, BITMAP_D_REMAINDER
	bne $t1, $t2, UPDATE_SHIP_D
	j main
	
BOOSTER_D_KEYPRESS:
	# check if right move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, ROW
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
	
	#reset ship address
	la $t1, SHIP_ADDRESS
	sw $t0, 0($t1)
	
	#update keyboard stack
	la $t0, LAST_KEYBOARD_INPUT
	sw $zero, 0($t0)
	
	#resetting asteroid locations
	li $t9, 0
	la $t8, ASTEROIDS
	la $t7, ASTEROID_TYPES
	j RESET_ASTEROIDS
	
RESET_ASTEROIDS:
	beq $t9, ASTEROID_COUNT, SETUP
	
	lw $t0, 0($t8)

	lw $t6, 0($t7)
	
	li $t1, BLACK
	li $t2, BLACK
	
	bltzal $t6, DRAW_BASIC_ASTEROID
	bgezal $t6, DRAW_COMPLEX_ASTEROID
	
	addi, $t8, $t8, 4
	addi, $t7, $t7, 4
	addi $t9, $t9, 1
	
######################################################################
