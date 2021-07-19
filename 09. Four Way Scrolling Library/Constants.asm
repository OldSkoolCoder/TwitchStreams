#importonce

//===============================================================================
// $00-$FF  PAGE .label Zero (256 bytes)
 
                // $00-$01   Reserved for IO
.label ZeroPageTemp    = $02
                // $03-$8F   Reserved for BASIC
                // using $73-$8A CHRGET as BASIC not used for our game
.label ZeroPageParam1  = $73
.label ZeroPageParam2  = $74
.label ZeroPageParam3  = $75
.label ZeroPageParam4  = $76
.label ZeroPageParam5  = $77
.label ZeroPageParam6  = $78
.label ZeroPageParam7  = $79
.label ZeroPageParam8  = $7A
.label ZeroPageParam9  = $7B
                // $90-$FA   Reserved for Kernal
.label ZeroPageLow     = $45
.label ZeroPageHigh    = $46
.label ZeroPageLow2    = $47
.label ZeroPageHigh2   = $48
                // $FF       Reserved for Kernal

//===============================================================================
// $0200-$9FFF  RAM (40K)

.label SCREENRAM        = $4000
.label SCREEN2RAM       = $4400
.label SPRITE0          = $43F8
.label SCREEN2SPRITE0   = SPRITE0 + $400  
.label COLOURRAM        = $D800

// $0801
// Game code is placed here by using the *=$0801 directive 
// in gameMain.asm 


// 192 decimal * 64(sprite size) = 10880(hex $2A80)
.label SPRITERAM       = 152 //170

//===============================================================================
// $D000-$DFFF  IO (4K)

// These are some of the C64 registers that are mapped into
// IO memory space
// Names taken from 'Mapping the Commodore 64' book

.label SP0X            = $D000
.label SP0Y            = $D001
.label MSIGX           = $D010
.label SCROLY          = $D011
.label RASTER          = $D012
.label SPENA           = $D015
.label SCROLX          = $D016
.label YXPAND          = $D017
.label VMCSB           = $D018
.label VICIRQ          = $D019
.label IRQMSK          = $D01A 
.label SPBGPR          = $D01B
.label SPMC            = $D01C
.label XXPAND          = $D01D
.label SPSPCL          = $D01E
.label SPBGCL          = $D01F
.label EXTCOL          = $D020
.label BGCOL0          = $D021
.label BGCOL1          = $D022
.label BGCOL2          = $D023
.label BGCOL3          = $D024
.label SPMC0           = $D025
.label SPMC1           = $D026
.label SP0COL          = $D027

.label FRELO1          = $D400 //(54272)
.label FREHI1          = $D401 //(54273)
.label PWLO1           = $D402 //(54274)
.label PWHI1           = $D403 //(54275)
.label VCREG1          = $D404 //(54276)
.label ATDCY1          = $D405 //(54277)
.label SUREL1          = $D406 //(54278)
.label FRELO2          = $D407 //(54279)
.label FREHI2          = $D408 //(54280)
.label PWLO2           = $D409 //(54281)
.label PWHI2           = $D40A //(54282)
.label VCREG2          = $D40B //(54283)
.label ATDCY2          = $D40C //(54284)
.label SUREL2          = $D40D //(54285)
.label FRELO3          = $D40E //(54286)
.label FREHI3          = $D40F //(54287)
.label PWLO3           = $D410 //(54288)
.label PWHI3           = $D411 //(54289)
.label VCREG3          = $D412 //(54290)
.label ATDCY3          = $D413 //(54291)
.label SUREL3          = $D414 //(54292)
.label SIGVOL          = $D418 //(54296)      
.label CIAPRA          = $DC00
.label CIAPRB          = $DC01

// Kernel Jump Vectors
.label krljmp_PCINT       = $FF81
.label krljmp_IOINIT      = $FF84
.label krljmp_RAMTAS      = $FF87
.label krljmp_RESTOR      = $FF8A
.label krljmp_VECTOR      = $FF8D
.label krljmp_SETMSG      = $FF90
.label krljmp_SECOND      = $FF93
.label krljmp_TKSA        = $FF96
.label krljmp_MEMTOP      = $FF99
.label krljmp_MEMBOT      = $FF9C
.label krljmp_SCNKEY      = $FF9F
.label krljmp_SETTMO      = $FFA2
.label krljmp_ACPTR       = $FFA5
.label krljmp_CIOUT       = $FFA8
.label krljmp_UNTALK      = $FFAB
.label krljmp_UNLSN       = $FFAE
.label krljmp_LISTEN      = $FFB1
.label krljmp_TALK        = $FFB4
.label krljmp_READST      = $FFB7
.label krljmp_SETLFS      = $FFBA
.label krljmp_SETNAM      = $FFBD
.label krljmp_OPEN        = $FFC0
.label krljmp_CLOSE       = $FFC3
.label krljmp_CHKIN       = $FFC6
.label krljmp_CHKOUT      = $FFC9
.label krljmp_CLRCHN      = $FFCC
.label krljmp_CHRIN       = $FFCF
.label krljmp_CHROUT      = $FFD2
.label krljmp_LOAD        = $FFD5
.label krljmp_SAVE        = $FFD8
.label krljmp_SETTIM      = $FFDB
.label krljmp_RDTIM       = $FFDE
.label krljmp_STOP        = $FFE1
.label krljmp_GETIN       = $FFE4
.label krljmp_CLALL       = $FFE7
.label krljmp_UDTIM       = $FFEA
.label krljmp_SCREEN      = $FFED
.label krljmp_PLOT        = $FFF0
.label krljmp_BASE        = $FFF3

.label krljmpLSTX         = 197

//Peek(197) Codes
.const scanCode_INS_DEL = 0
.const scanCode_RET = 1
.const scanCode_CUR_RI = 2 
.const scanCode_F7 = 3
.const scanCode_F1 = 4
.const scanCode_F3 = 5 
.const scanCode_F5 = 6 
.const scanCode_CUR_DN = 7 
.const scanCode_3 = 8 
.const scanCode_W = 9 
.const scanCode_A = 10
.const scanCode_4 = 11
.const scanCode_Z = 12
.const scanCode_S = 13
.const scanCode_E = 14
.const scanCode_5 = 16
.const scanCode_R = 17
.const scanCode_D = 18
.const scanCode_6 = 19
.const scanCode_C = 20
.const scanCode_F = 21
.const scanCode_T = 22
.const scanCode_X = 23
.const scanCode_7 = 24
.const scanCode_Y = 25
.const scanCode_G = 26
.const scanCode_8 = 27
.const scanCode_B = 28
.const scanCode_H = 29
.const scanCode_U = 30
.const scanCode_V = 31
.const scanCode_9 = 32
.const scanCode_I = 33
.const scanCode_J = 34
.const scanCode_0 = 35
.const scanCode_M = 36
.const scanCode_K = 37
.const scanCode_O = 38
.const scanCode_N = 39
.const scanCode_PLUS = 40
.const scanCode_P = 41
.const scanCode_L = 42
.const scanCode_MINUS = 43
.const scanCode_FULSTP = 44
.const scanCode_COLON = 45
.const scanCode_AT = 46
.const scanCode_COMMA = 47
.const scanCode_POUND = 48
.const scanCode_ASTRIK = 49
.const scanCode_SEMICOLON = 50
.const scanCode_CLEAR_HOME = 51
.const scanCode_EQUALS = 53
.const scanCode_EXPONENT_ARROW = 54
.const scanCode_FWD_SLASH = 55
.const scanCode_1 = 56
.const scanCode_LEFT_ARROW = 57
.const scanCode_2 = 59
.const scanCode_SPACEBAR = 60
.const scanCode_Q = 62
.const scanCode_RUNSTOP = 63
.const scanCode_NO_KEY = 64

.const joystickUp       = %00000001
.const joystickDown     = %00000010
.const joystickLeft     = %00000100
.const joystickRight    = %00001000
.const joystickFire     = %00010000