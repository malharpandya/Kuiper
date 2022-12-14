######################################################################
# CSCB58 Summer 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Malhar Pandya, 1005893008, pandyam8
# Student: Yara Radwan, 1006280748, radwanya
#
# Bitmap Display Configuration:
# -Unit width in pixels: 8 
# -Unit height in pixels: 8
# -Display width in pixels: 256
# -Display height in pixels: 512
# -Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1, 2, 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. smooth graphics
# 2. grazing
# 3. increasing difficulty
# 4. power-ups
# 5. sound effects on sprite collision + game over
#
# Link to video demonstration for final submission:
# - https://youtu.be/t9_FH-fKG_s
#
# Are you OK with us sharing the video with people outside course staff?
# - no
#
# Any additional information that the TA needs to know:
# - We decided to make this game a vertical shooter based on our personal taste in 
# - f.p.s games.
######################################################################

# DECLARING CONSTANTS

#Addresses
.eqv KEYBOARD_ADDRESS 0xffff0000
.eqv RESET_ADDRESS 0x10009d3c
.eqv BASE_ADDRESS 0x10008000
.eqv TOP_ADDRESS 0x10007d00
.eqv BOTTOM_ADDRESS 0x1000a080

# Movement Related
.eqv BITMAP_W_LIMIT 0x10008070
.eqv BITMAP_S_LIMIT 0x10009d08
.eqv BITMAP_A_REMAINDER 8
.eqv BITMAP_D_REMAINDER 112

.eqv BOOSTER_BITMAP_W_LIMIT 0x100080ec
.eqv BOOSTER_BITMAP_S_LIMIT 0x10009c8c
.eqv BOOSTER_BITMAP_A_REMAINDER 12
.eqv BOOSTER_BITMAP_D_REMAINDER 108

.eqv ROW 128
.eqv COLUMN 4

#Randomness
.eqv X_RANDOMNESS_THRESHOLD 30
.eqv Y_RANDOMNESS_THRESHOLD 128
.eqv X_FIXED_DELTA 1

#Game constants
.eqv INIT_REFRESH_RATE 60
.eqv REFRESH_RATE_REDUCTION 5
.eqv REDUCTION_FREQUENCY 250
.eqv ASTEROID_COUNT 8
.eqv ASTEROID_TYPE_COUNT 2
.eqv Y_DELTA_POWERUP 100

# Colours
.eqv SHIP_COLOUR 0x7daffa # light blue
.eqv BLACK 0x000000 # for redrawing
.eqv WHITE 0xffffff # for background
.eqv RED 0xff0000 # for collision
.eqv HEALTH_BAR_RED 0xff0001 # for health bar
.eqv GREEN 0x00ff00 #for health powerup
.eqv HEALTH_BAR_GREEN 0x00ff01 #for health bar
.eqv ORANGE 0xff7600 #for collision

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

# Health related
.eqv HEALTH_INIT 20
.eqv HEALTH_INCREASE 5 # 25 percent
.eqv DAMAGE_SIDE_BASIC 1 # 5 percent
.eqv DAMAGE_SIDE_COMPLEX 2 # 10 percent
.eqv DAMAGE_TOP_BASIC 3 # 15 percent
.eqv DAMAGE_TOP_COMPLEX 4 # 20 percent

# Sound constants
.eqv COLLISION_INSTRUMENT 127 # low bass
.eqv POWERUP_INSTRUMENT 120
.eqv GAME_OVER_INSTRUMENT 58 # tuba
.eqv TOP_COLLISION_NOTE 60 # low pitched beep
.eqv SIDE_COLLISION_NOTE 65 # slighly higher pitched beep

.eqv POWERUP_NOTE 71 # very high pitched beep

.eqv PITCH_G 68 # G# / Gsharp
.eqv PITCH_E 65 # E# / Esharp
.eqv PITCH_C 58 # C
.eqv VOLUME 50 # medium volume
.eqv NOTE_LENGTH 400 # ms
.eqv GAME_OVER_NOTE_LENGTH 600 # ms

.data
	REFRESH_RATE: INIT_REFRESH_RATE
	SHIP_ADDRESS: .word RESET_ADDRESS #address
	ASTEROIDS: .word 0:ASTEROID_COUNT #array of pointers
    	ASTEROID_TYPES: .word 0:ASTEROID_COUNT
   	POWERUPS: .word 0:2 #address [health, speed]
   	SPEED_POWERUP_FLAG: .word 0#flag
	LAST_KEYBOARD_INPUT: .word 0
	HEALTH: HEALTH_INIT
	FRAME_COUNTER: .word 0
	

.text

.globl main
	
	
############################# INITIALIZE #############################	

SETUP:
	# draw the ship initially and jump to main
	la $t0, SHIP_ADDRESS
	lw, $t0, 0($t0)
	li $t1, SHIP_COLOUR
	jal DRAW_SHIP_INIT
	
	li $t9, 0
	la $t1, POWERUPS
	jal GENERATE_POWERUPS
	
    	li $t9, 0 # counter
    	la $t8, ASTEROIDS
    	la $t7, ASTEROID_TYPES
	jal GENERATE_ASTEROIDS
	
	j main
	
JUMP_BACK:
	jr $ra

# acts as main refresh loop
main:
	la $t0, FRAME_COUNTER
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	
	jal UPDATE_REFRESH_RATE
	
	jal UPDATE_HEALTH_BAR
	
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
		
UPDATE_REFRESH_RATE:
	li $t2, REDUCTION_FREQUENCY
	div $t1, $t2
	mfhi $t1
	beqz $t1, REDUCE_FREQUENCY
	jr $ra
	
REDUCE_FREQUENCY:
	la $t0, REFRESH_RATE
	lw $t1, 0($t0)
	beqz $t1, JUMP_BACK
	subi, $t1, $t1, REFRESH_RATE_REDUCTION
	sw $t1, 0($t0)
	jr $ra
    
CHECK_INPUT:
	# check for keyboard input and branch accordingly
	li $t0, KEYBOARD_ADDRESS
	lw $t1, 0($t0)
	beq $t1, 1, KEYPRESS
	j NO_KEYPRESS
	
######################################################################



########################## DRAWING SECTION ##########################
	
DRAW_HEALTH:
	beq $t9, $t7, DRAW_DAMAGE
	sw $t2, 132($t0)
	addi $t0, $t0, 4
	addi $t9, $t9, 1
	j DRAW_HEALTH
	
DRAW_DAMAGE:
	beq $t9, HEALTH_INIT, JUMP_BACK
	sw $t1, 132($t0)
	addi $t0, $t0, 4
	addi $t9, $t9, 1
	j DRAW_DAMAGE
	
DRAW_HEALTH_POWERUP:
	sw $t1, -132($t0)
	sw $t1, -128($t0)
	sw $t1, -124($t0)
	
	sw $t1, -4($t0)
	sw $t1, 4($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	jr $ra
	
DRAW_SPEED_POWERUP:
	sw $t1, -128($t0)
	sw $t1, -124($t0)
	
	sw $t1, -4($t0)
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t2, 124($t0)
	sw $t1, 128($t0)

	jr $ra
	
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

DRAW_GAME_OVER:
        # colour yellow section for GAME (first row)
        # G
        sw $t1, 2060($t0) 
        sw $t1, 2064($t0)  
	sw $t1, 2068($t0)  
	sw $t1, 2072($t0)
	
	sw $t1, 2184($t0) 
	sw $t1, 2204($t0) 
	
	# A
        sw $t1, 2088($t0)
	sw $t1, 2092($t0)
	sw $t1, 2096($t0)
	sw $t1, 2100($t0)
	sw $t1, 2104($t0)
	
	sw $t1, 2216($t0)
	sw $t1, 2232($t0)
	
	# M
	sw $t1, 2116($t0)
	sw $t1, 2120($t0)
	sw $t1, 2136($t0)
	sw $t1, 2140($t0)
	sw $t1, 2244($t0)
	sw $t1, 2252($t0)
	sw $t1, 2260($t0)
	sw $t1, 2268($t0)
	
	# E
	sw $t1, 2152($t0)
	sw $t1, 2156($t0)
	sw $t1, 2160($t0)
	sw $t1, 2164($t0)
	sw $t1, 2168($t0)
	
	sw $t1, 2280($t0)

	
	# colour light peach section for GAME
	# G
	sw $t2, 2308($t0)
	sw $t2, 2436($t0)
	
	# A
	sw $t2, 2344($t0)
	sw $t2, 2360($t0)
	sw $t2, 2472($t0)
	sw $t2, 2488($t0)
	
	# M
	sw $t2, 2372($t0)
	sw $t2, 2500($t0)
	
	sw $t2, 2384($t0)

	sw $t2, 2396($t0)
	sw $t2, 2524($t0)
	
	# E
	sw $t2, 2408($t0)
	sw $t2, 2536($t0)
	
	# colour peach section for GAME (first row)
	# G
	sw $t3, 2564($t0)
	sw $t3, 2692($t0)
	sw $t3, 2820($t0)
	sw $t3, 2844($t0)
	sw $t3, 2716($t0)
	sw $t3, 2712($t0)
	sw $t3, 2708($t0)
	
	# A
	sw $t3, 2600($t0)
	sw $t3, 2604($t0)
	sw $t3, 2608($t0)
	sw $t3, 2612($t0)
	
	sw $t3, 2728($t0)
	sw $t3, 2856($t0)
	
	sw $t3, 2616($t0)
	sw $t3, 2744($t0)
	sw $t3, 2872($t0)
	
	# M
	sw $t3, 2628($t0)
	sw $t3, 2756($t0)
	sw $t3, 2884($t0)
		
	sw $t3, 2652($t0)
	sw $t3, 2780($t0)
	sw $t3, 2908($t0)
	
	# E
	sw $t3, 2664($t0)
	sw $t3, 2668($t0)
	sw $t3, 2672($t0)
	sw $t3, 2676($t0)
	
	sw $t3, 2792($t0)
	
	sw $t3, 2920($t0)
	
	
	# colour pink section for GAME
	# G
	sw $t4, 2952($t0)
	sw $t4, 3084($t0)
	
	sw $t4, 3088($t0)
	sw $t4, 3092($t0)
	sw $t4, 3096($t0)
	
	sw $t4, 2972($t0)
	
	# A
	sw $t4, 2984($t0)
	sw $t4, 3112($t0)
	
	sw $t4, 3000($t0)
	sw $t4, 3128($t0)
	
	# M
	sw $t4, 3012($t0)
	sw $t4, 3140($t0)
	
	sw $t4, 3036($t0)
	sw $t4, 3164($t0)
	
	# E
	sw $t4, 3048($t0)
	sw $t4, 3176($t0)
	
	sw $t4, 3180($t0)
	sw $t4, 3184($t0)
	sw $t4, 3188($t0)
	sw $t4, 3192($t0)
	
	
	# colour pink section for OVER
	
	# O
	sw $t4, 3464($t0)
	sw $t4, 3468($t0)
	sw $t4, 3472($t0)
	sw $t4, 3476($t0)
	sw $t4, 3480($t0)
	
	sw $t4, 3588($t0)
	sw $t4, 3612($t0)
	
	
	# V
	sw $t4, 3496($t0)
	sw $t4, 3512($t0)
	
	sw $t4, 3624($t0)
	sw $t4, 3640($t0)
	
	
	# E
	sw $t4, 3524($t0)
	sw $t4, 3528($t0)
	sw $t4, 3532($t0)
	sw $t4, 3536($t0)
	sw $t4, 3540($t0)
	
	sw $t4, 3652($t0)
	
	
	# R
	sw $t4, 3552($t0)
	sw $t4, 3556($t0)
	sw $t4, 3560($t0)
	sw $t4, 3564($t0)
	sw $t4, 3568($t0)
	
	sw $t4, 3680($t0)
	sw $t4, 3700($t0)
	
	
	# colour peach section for OVER
	# O
	sw $t3, 3716($t0)
	sw $t3, 3844($t0)
	
	sw $t3, 3740($t0)
	sw $t3, 3868($t0)
	
	# V
	sw $t3, 3752($t0)
	sw $t3, 3880($t0)
	
	sw $t3, 3768($t0)
	sw $t3, 3896($t0)
	
	
	# E
	sw $t3, 3780($t0)
	sw $t3, 3908($t0)
	
	
	# R
	sw $t3, 3808($t0)
	sw $t3, 3936($t0)
	
	sw $t3, 3828($t0)
	sw $t3, 3956($t0)


	# colour light peach section for OVER
	# O
	sw $t2, 3972($t0)
	sw $t2, 4100($t0)
	sw $t2, 4228($t0)
	
	sw $t2, 3996($t0)
	sw $t2, 4124($t0)
	sw $t2, 4252($t0)
	
	
	# V
	sw $t2, 4008($t0)
	sw $t2, 4136($t0)
	sw $t2, 4264($t0)
	
	sw $t2, 4024($t0)
	sw $t2, 4152($t0)
	sw $t2, 4280($t0)
	
	
	# E
	sw $t2, 4036($t0)
	sw $t2, 4040($t0)
	sw $t2, 4044($t0)
	sw $t2, 4048($t0)
	
	sw $t2, 4164($t0)
	sw $t2, 4292($t0)
	
	# R
	sw $t2, 4064($t0)
	sw $t2, 4068($t0)
	sw $t2, 4072($t0)
	sw $t2, 4076($t0)
	sw $t2, 4080($t0)
	
	sw $t2, 4192($t0)
	sw $t2, 4320($t0)
	
	sw $t2, 4212($t0)
	sw $t2, 4340($t0)
	
	
	# colour yellow section for OVER
	# O
	sw $t1, 4356($t0)
	sw $t1, 4380($t0)
	sw $t1, 4504($t0)
	sw $t1, 4500($t0)
	sw $t1, 4496($t0)
	sw $t1, 4492($t0)
	sw $t1, 4488($t0)
	
	# V
	sw $t1, 4396($t0)
	sw $t1, 4528($t0)
	
	sw $t1, 4404($t0)
	
	# E
	sw $t1, 4420($t0)
	sw $t1, 4548($t0)
	
	sw $t1, 4552($t0)
	sw $t1, 4556($t0)
	sw $t1, 4560($t0)
	sw $t1, 4564($t0)
	
	# R
	sw $t1, 4448($t0)
	sw $t1, 4576($t0)
	
	sw $t1, 4468($t0)
	sw $t1, 4596($t0)
	
	jr $ra

######################################################################



######################### ASTEROIDS/POWERUPS #########################
GENERATE_POWERUPS:

	beq $t9, 2, JUMP_BACK

	li $t0, BASE_ADDRESS
	# generate x_axis randomness
    	li $v0, 42
	li $a0, 0
	li $a1, X_RANDOMNESS_THRESHOLD
    	syscall
    	move $t2, $a0
    	addi $t2, $t2, X_FIXED_DELTA
    
    	# update asteroid address horizontal
    	li $t3, COLUMN
    	mult $t2, $t3
    	mflo $t2
    	add $t0, $t0, $t2
    
    	# generate y_axis randomness
	li $v0, 42
	li $a0, 0
	li $a1, Y_RANDOMNESS_THRESHOLD
    	syscall
    	move $t2, $a0
    	addi $t2, $t2, Y_DELTA_POWERUP # fixed vertical offset
    
    	# update asteroid address vertical
    	li $t3, ROW
    	mult $t2, $t3
    	mflo $t2
    	sub $t0, $t0, $t2
    	
    	sw $t0, 0($t1)
    	
    	addi $t1, $t1, 4
    	addi $t9, $t9, 1
	j GENERATE_POWERUPS
	
GENERATE_ASTEROIDS:
	beq $t9, ASTEROID_COUNT, JUMP_BACK
	
    	li $t0, BASE_ADDRESS
    	
    	# generate x_axis randomness
    	li $v0, 42
	li $a0, 0
	li $a1, X_RANDOMNESS_THRESHOLD
    	syscall
    	move $t6, $a0
    	addi $t6, $t6, X_FIXED_DELTA
    
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
    
    	# update address and type in memory
    	sw $t0, 0($t8)
    	sw $t6, 0($t7)
    
    	# loop increment
    	addi $t7, $t7, 4
    	addi $t8, $t8, 4

	addi $t9, $t9, 1
	
	j GENERATE_ASTEROIDS

UPDATE_ASTEROIDS:

	beq $t9, ASTEROID_COUNT, UPDATE_POWERUPS_PARENT #CHECK_COLLISION
    	lw $t0, 0($t8)
    	
    	#check if asteroid above the bitmap
    	li $t6, TOP_ADDRESS
    	blt $t0, $t6, UPDATE_ASTEROID_DRAWLESS
    	
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
	
	# generate x_axis randomness
    	li $v0, 42
	li $a0, 0
	li $a1, X_RANDOMNESS_THRESHOLD
    	syscall
    	move $t6, $a0
    	addi $t6, $t6, X_FIXED_DELTA
    
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
       	
       	sw $t6, 0($t7)
       	
       	# update address in memory
    	sw $t0, 0($t8)
    	
       	# loop increment
    	addi $t7, $t7, 4
    	addi $t8 $t8, 4

	addi $t9, $t9, 1
	
	j UPDATE_ASTEROIDS

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

UPDATE_POWERUPS_PARENT:
	li $t9, 0
	la $t8, POWERUPS
	j UPDATE_POWERUPS

UPDATE_POWERUPS:
	beq $t9, 2, CHECK_COLLISION
	
	lw $t0, 0($t8)
	
	#check if powerup above the bitmap
    	li $t7, TOP_ADDRESS
    	blt $t0, $t7, UPDATE_POWERUP_DRAWLESS
    	
    	#check if powerup below the bitmap
    	li $t7, BOTTOM_ADDRESS
    	bgt $t0, $t7, LOOP_POWERUP
    	
    	beqz $t9, UPDATE_HEALTH_POWERUP
    	
    	j UPDATE_SPEED_POWERUP
    	
UPDATE_POWERUP_DRAWLESS:
	addi $t0, $t0, ROW
	sw $t0, 0($t8)
	
	addi $t8, $t8, 4
	addi $t9, $t9, 1
	j UPDATE_POWERUPS
	
LOOP_POWERUP:

	li $t0, BASE_ADDRESS
	# generate x_axis randomness
    	li $v0, 42
	li $a0, 0
	li $a1, X_RANDOMNESS_THRESHOLD
    	syscall
    	move $t2, $a0
    	addi $t2, $t2, X_FIXED_DELTA
    
    	# update asteroid address horizontal
    	li $t3, COLUMN
    	mult $t2, $t3
    	mflo $t2
    	add $t0, $t0, $t2
    
    	# generate y_axis randomness
	li $v0, 42
	li $a0, 0
	li $a1, Y_RANDOMNESS_THRESHOLD
    	syscall
    	move $t2, $a0
    	addi $t2, $t2, Y_DELTA_POWERUP # fixed vertical offset
    
    	# update asteroid address vertical
    	li $t3, ROW
    	mult $t2, $t3
    	mflo $t2
    	sub $t0, $t0, $t2
    	
    	sw $t0, 0($t8)
    	
    	addi $t8, $t8, 4
    	addi $t9, $t9, 1
	j UPDATE_POWERUPS
	
UPDATE_HEALTH_POWERUP:
	li $t1 BLACK
	jal DRAW_HEALTH_POWERUP
	
	addi $t0, $t0, ROW
	
	li $t1, GREEN
	jal DRAW_HEALTH_POWERUP
	
	sw $t0, 0($t8)
	
	addi $t8, $t8, 4
	addi $t9, $t9, 1
	j UPDATE_POWERUPS
	
UPDATE_SPEED_POWERUP:
	li $t1 BLACK
	li $t2 BLACK
	jal DRAW_SPEED_POWERUP
	
	addi $t0, $t0, ROW
	
	li $t1, YELLOW
	li $t2, RED
	jal DRAW_SPEED_POWERUP
	
	sw $t0, 0($t8)
	
	addi $t8, $t8, 4
	addi $t9, $t9, 1
	j UPDATE_POWERUPS

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
	beq $t0, 0x70, RESET # ASCII code of 'p' is 0x70
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
	la $t0, SPEED_POWERUP_FLAG
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
	la $t0, SPEED_POWERUP_FLAG
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
	la $t0, SPEED_POWERUP_FLAG
	lw $t0, 0($t0)
	bgtz $t0 BOOSTER_A_KEYPRESS
	
	# check if left move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, ROW
	div $t0, $t1
	mfhi $t1
	li $t2, BITMAP_A_REMAINDER
	bgt $t1, $t2, UPDATE_SHIP_A
	j main
	
BOOSTER_A_KEYPRESS:
	#check if left move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, ROW
	div $t0, $t1
	mfhi $t1
	li $t2, BOOSTER_BITMAP_A_REMAINDER
	bgt $t1, $t2, BOOSTER_UPDATE_SHIP_A
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
	la $t0, SPEED_POWERUP_FLAG
	lw $t0, 0($t0)
	bgtz $t0 BOOSTER_D_KEYPRESS
	
	# check if right move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, ROW
	div $t0, $t1
	mfhi $t1
	li $t2, BITMAP_D_REMAINDER
	blt $t1, $t2, UPDATE_SHIP_D
	j main
	
BOOSTER_D_KEYPRESS:
	# check if right move is possible
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	li $t1, ROW
	div $t0, $t1
	mfhi $t1
	li $t2, BOOSTER_BITMAP_D_REMAINDER
	blt $t1, $t2, BOOSTER_UPDATE_SHIP_D
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

RESET:

	#Reset refresh rate
	la $t0, REFRESH_RATE
	li $t1, INIT_REFRESH_RATE
	sw $t1, 0($t0)
	
	#Reset All Powerup Flags
	la $t0, SPEED_POWERUP_FLAG
	sw $zero, 0($t0)
	
	
	#Reset Health
	la $t0, HEALTH
	li $t1, HEALTH_INIT
	sw $t1, 0($t0)
	
	#draw health bar
	la $t7, HEALTH
	lw $t7, 0($t7)
	li $t9, 0
	li $t0, BASE_ADDRESS
	li $t1, HEALTH_BAR_RED
	li $t2, HEALTH_BAR_GREEN
	jal DRAW_HEALTH
	
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	# erase ship
	li $t1, BLACK
	jal DRAW_SHIP_INIT
	
	li $t0, RESET_ADDRESS
	
	# reset ship address
	la $t1, SHIP_ADDRESS
	sw $t0, 0($t1)
	
	# update keyboard stack
	la $t0, LAST_KEYBOARD_INPUT
	sw $zero, 0($t0)
	
	# resetting asteroid locations
	li $t9, 0
	la $t8, ASTEROIDS
	la $t7, ASTEROID_TYPES
	j RESET_ASTEROIDS
	
RESET_ASTEROIDS:
	beq $t9, ASTEROID_COUNT, RESET_POWERUPS_PARENT
	
	lw $t0, 0($t8)

	lw $t6, 0($t7)
	
	li $t1, BLACK
	li $t2, BLACK
	
	bltzal $t6, DRAW_BASIC_ASTEROID
	bgezal $t6, DRAW_COMPLEX_ASTEROID
	
	addi, $t8, $t8, 4
	addi, $t7, $t7, 4
	addi $t9, $t9, 1
	
	j RESET_ASTEROIDS
	
RESET_POWERUPS_PARENT:
	li $t9, 0
	la $t8, POWERUPS
	j RESET_POWERUPS

RESET_POWERUPS:
	beq $t9, 2, SETUP
	
	lw $t0, 0($t8)
	
	li $t1, BLACK
	li $t2, BLACK
	
	subi $t7, $t9, 1
	bltzal $t7, DRAW_HEALTH_POWERUP
	bgezal $t7, DRAW_SPEED_POWERUP
	
	addi, $t8, $t8, 4
	addi $t9, $t9, 1
	
	j RESET_POWERUPS
	
######################################################################



############################# COLLISIONS #############################
CHECK_COLLISION:
	
	la $t8, SHIP_ADDRESS
	
	# Check first row
	lw $t7, 0($t8)
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	addi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	# Check second row
	addi $t7, $t7, 132
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	subi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	subi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	subi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	# Check third row
	addi $t7, $t7, 124
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	addi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	addi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	addi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	addi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	addi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	# Check fourth row
	addi $t7, $t7, 128
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	subi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	subi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	subi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	subi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	subi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	# Check fifth row
	addi $t7, $t7, 128
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	addi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	addi $t7, $t7, 12
	lw $t6, 0($t7)
	jal CHECK_COLLISION_TOP
	
	addi $t7, $t7, 4
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	# Check sixth row
	addi $t7, $t7, 128
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	subi $t7, $t7, 20
	lw $t6, 0($t7)
	jal CHECK_COLLISION_SIDE
	
	# If this line it reached, that means no collision has happened
	j CHECK_INPUT
	
CHECK_COLLISION_TOP:
	beq $t6, LIGHT_GRAY, BASIC_COLLISION_TOP
	beq $t6, GRAY, BASIC_COLLISION_TOP
	
	beq $t6, LIGHT_BROWN, COMPLEX_COLLISION_TOP
	beq $t6, BROWN, COMPLEX_COLLISION_TOP
	
	beq $t6, GREEN, HEALTH_POWERUP_COLLISION
	beq $t6, RED, SPEED_POWERUP_COLLISION
	beq $t6, YELLOW, SPEED_POWERUP_COLLISION
	jr $ra
	
CHECK_COLLISION_SIDE:
	beq $t6, LIGHT_GRAY, BASIC_COLLISION_SIDE
	beq $t6, GRAY, BASIC_COLLISION_SIDE
	
	beq $t6, LIGHT_BROWN, COMPLEX_COLLISION_SIDE
	beq $t6, BROWN, COMPLEX_COLLISION_SIDE
	
	beq $t6, GREEN, HEALTH_POWERUP_COLLISION
	beq $t6, RED, SPEED_POWERUP_COLLISION
	beq $t6, YELLOW, SPEED_POWERUP_COLLISION
	jr $ra
		
BASIC_COLLISION_TOP:
	la $t8, HEALTH
	lw $t7, 0($t8)
	subi $t7, $t7, DAMAGE_TOP_BASIC
	
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	#draw ship red to indicate collision
	li $t1, RED
	jal DRAW_SHIP_INIT
		
	# play (top) collision sound
	li $v0, 33
	li $a0, TOP_COLLISION_NOTE
	li $a1, NOTE_LENGTH
	li $a2, COLLISION_INSTRUMENT 
	li $a3, VOLUME
	syscall
	
	sw $t7, 0($t8)
	j CHECK_GAME_OVER
	
BASIC_COLLISION_SIDE:
	la $t8, HEALTH
	lw $t7, 0($t8)
	subi $t7, $t7, DAMAGE_SIDE_BASIC
	
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	#draw ship red to indicate collision
	li $t1, ORANGE
	jal DRAW_SHIP_INIT
	
	# play (side) collision sound
	li $v0, 33
	li $a0, SIDE_COLLISION_NOTE
	li $a1, NOTE_LENGTH
	li $a2, COLLISION_INSTRUMENT
	li $a3, VOLUME
	syscall
	
	
	sw $t7, 0($t8)
	j CHECK_GAME_OVER

COMPLEX_COLLISION_TOP:
	la $t8, HEALTH
	lw $t7, 0($t8)
	subi $t7, $t7, DAMAGE_TOP_COMPLEX
	
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	#draw ship red to indicate collision
	li $t1, RED
	jal DRAW_SHIP_INIT
	
	# play (top) collision sound
	li $v0, 33
	li $a0, TOP_COLLISION_NOTE
	li $a1, NOTE_LENGTH
	li $a2, COLLISION_INSTRUMENT 
	li $a3, VOLUME
	syscall
	
	
	sw $t7, 0($t8)
	j CHECK_GAME_OVER
	
COMPLEX_COLLISION_SIDE:
	la $t8, HEALTH
	lw $t7, 0($t8)
	subi $t7, $t7, DAMAGE_SIDE_COMPLEX
	
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	
	#draw ship red to indicate collision
	li $t1, ORANGE
	jal DRAW_SHIP_INIT
	
	# play (side) collision sound
	li $v0, 33
	li $a0, SIDE_COLLISION_NOTE
	li $a1, NOTE_LENGTH
	li $a2, COLLISION_INSTRUMENT
	li $a3, VOLUME
	syscall

	sw $t7, 0($t8)
	j CHECK_GAME_OVER

HEALTH_POWERUP_COLLISION:

	#remove powerup
	la $t9, POWERUPS
	lw $t0, 0($t9)
	li $t1, BLACK
	jal DRAW_HEALTH_POWERUP
	
	# play powerup collision sound
	li $v0, 33
	li $a0, POWERUP_NOTE
	li $a1, NOTE_LENGTH
	li $a2, POWERUP_INSTRUMENT 
	li $a3, VOLUME
	syscall
	
	#reset the powerup ramdomly
	li $t0, BASE_ADDRESS
	# generate x_axis randomness
    	li $v0, 42
	li $a0, 0
	li $a1, X_RANDOMNESS_THRESHOLD
    	syscall
    	move $t2, $a0
    	addi $t2, $t2, X_FIXED_DELTA
    
    	# update powerup address horizontal
    	li $t3, COLUMN
    	mult $t2, $t3
    	mflo $t2
    	add $t0, $t0, $t2
    
    	# generate y_axis randomness
	li $v0, 42
	li $a0, 0
	li $a1, Y_RANDOMNESS_THRESHOLD
    	syscall
    	move $t2, $a0
    	addi $t2, $t2, Y_DELTA_POWERUP # fixed vertical offset
    
    	# update powerup address vertical
    	li $t3, ROW
    	mult $t2, $t3
    	mflo $t2
    	sub $t0, $t0, $t2
    	
    	sw $t0, 0($t9)
	
	#redraw the ship
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	li $t1, GREEN
	jal DRAW_SHIP_INIT
	
	#redraw the ship
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	li $t1, SHIP_COLOUR
	jal DRAW_SHIP_INIT
	
	#update the health
	la $t1, HEALTH
	lw $t0, 0($t1)
	addi $t0, $t0, HEALTH_INCREASE
	
	bgt $t0, HEALTH_INIT, SET_HEALTH_MAX
	
	sw $t0, 0($t1)
	
	#update the health bar
	
	jal UPDATE_HEALTH_BAR
	
	j CHECK_INPUT
	
SET_HEALTH_MAX:
	li $t0, HEALTH_INIT
	sw $t0, 0($t1)
	jal UPDATE_HEALTH_BAR
	j CHECK_INPUT

SPEED_POWERUP_COLLISION:
	#remove powerup
	la $t9, POWERUPS
	lw $t0, 4($t9)
	li $t1, BLACK
	li $t2, BLACK
	jal DRAW_SPEED_POWERUP
	
	# play powerup collision sound
	li $v0, 33
	li $a0, POWERUP_NOTE
	li $a1, NOTE_LENGTH
	li $a2, POWERUP_INSTRUMENT
	li $a3, VOLUME
	syscall
	
	#reset the powerup ramdomly
	li $t0, BASE_ADDRESS
	# generate x_axis randomness
    	li $v0, 42
	li $a0, 0
	li $a1, X_RANDOMNESS_THRESHOLD
    	syscall
    	move $t2, $a0
    	addi $t2, $t2, X_FIXED_DELTA
    
    	# update powerup address horizontal
    	li $t3, COLUMN
    	mult $t2, $t3
    	mflo $t2
    	add $t0, $t0, $t2
    
    	# generate y_axis randomness
	li $v0, 42
	li $a0, 0
	li $a1, Y_RANDOMNESS_THRESHOLD
    	syscall
    	move $t2, $a0
    	addi $t2, $t2, Y_DELTA_POWERUP # fixed vertical offset
    
    	# update powerup address vertical
    	li $t3, ROW
    	mult $t2, $t3
    	mflo $t2
    	sub $t0, $t0, $t2
    	
    	sw $t0, 4($t9)
    	
    	#redraw the ship
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	li $t1, YELLOW
	jal DRAW_SHIP_INIT
	
	#redraw the ship
	la $t0, SHIP_ADDRESS
	lw $t0, 0($t0)
	li $t1, SHIP_COLOUR
	jal DRAW_SHIP_INIT
	
	#update the speed flag
	la $t1, SPEED_POWERUP_FLAG
	li $t0, 1
	sw $t0, 0($t1)
	
	j CHECK_INPUT


CHECK_GAME_OVER:
	la $t8, HEALTH
	lw $t7, 0($t8)
	blez $t7, END_GAME
	j COLLISION_RESET
	
COLLISION_RESET:
	# erase ship
	li $t1, BLACK
	jal DRAW_SHIP_INIT
	
	jal UPDATE_HEALTH_BAR
	
	li $t0, RESET_ADDRESS
	
	# reset ship address
	la $t1, SHIP_ADDRESS
	sw $t0, 0($t1)
	
	#Reset All Powerup Flags
	la $t0, SPEED_POWERUP_FLAG
	sw $zero, 0($t0)
	
	# update keyboard stack
	la $t0, LAST_KEYBOARD_INPUT
	sw $zero, 0($t0)
	
	# resetting asteroid locations
	li $t9, 0
	la $t8, ASTEROIDS
	la $t7, ASTEROID_TYPES
	j RESET_ASTEROIDS
	
UPDATE_HEALTH_BAR:
	la $t7, HEALTH
	lw $t7, 0($t7)
	li $t9, 0
	li $t0, BASE_ADDRESS
	li $t1, HEALTH_BAR_RED
	li $t2, HEALTH_BAR_GREEN
	j DRAW_HEALTH
	
######################################################################	



############################# GAME OVER ##############################		
						
END_GAME:
	la $t0, HEALTH
	sw $zero, 0($t0)
	jal UPDATE_HEALTH_BAR
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	li $t1, YELLOW 
	li $t2, PEACH
	li $t3, SALMON
	li $t4, PINK
	
	jal DRAW_GAME_OVER # draw the game over test
	
	# play game over sound
	li $v0, 33
	li $a0, PITCH_G
	li $a1, GAME_OVER_NOTE_LENGTH
	li $a2, GAME_OVER_INSTRUMENT
	li $a3, VOLUME
	syscall
	
	li $v0, 33
	li $a0, PITCH_E
	li $a1, GAME_OVER_NOTE_LENGTH
	li $a2, GAME_OVER_INSTRUMENT
	li $a3, VOLUME
	syscall
	
	li $v0, 33
	li $a0, PITCH_C
	li $a1, GAME_OVER_NOTE_LENGTH
	li $a2, GAME_OVER_INSTRUMENT
	li $a3, VOLUME
	syscall
	
	j WAIT_FOR_USER_RESTART


WAIT_FOR_USER_RESTART:
	li $v0, 32
	li $a0, 100
	li $t0, KEYBOARD_ADDRESS 
	lw $t1, 0($t0)
	beq $t1, 1, END_KEYPRESS # if keyboard input received, branch
	j WAIT_FOR_USER_RESTART


END_KEYPRESS:
	# check if any valid key was pressed 
	lw $t0, 4($t0)
	beq $t0, 0x70, ERASE_GAME_OVER # if user pressed p, erase game over screen
	
	j WAIT_FOR_USER_RESTART

ERASE_GAME_OVER:
	li $t0, BASE_ADDRESS # $t0 stores the base address for display
	li $t1, BLACK 
	li $t2, BLACK
	li $t3, BLACK
	li $t4, BLACK
	jal DRAW_GAME_OVER
	# need to reset the asteroids and ship
	j RESET
