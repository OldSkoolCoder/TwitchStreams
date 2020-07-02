#import "Constants.asm"

//====================================================================
BasicUpstart2(start)

.label PRINT_LINE   = $AB1E
.label QuazzyDirection = $02A7
.label FrameCounter = $02A8
.label SpriteFrameCounter = $02A9
.label Jumping = $02AA
.label JumpIndex = $02AB

.label QuazzyRight = 170
.label QuazzyLeft = 174
.label QuazzyJumpRight = 186

JumpArk:
    //.byte 0, 2, 4, 8, 12, 18, 18, 12,  8,  4,  2,  0
    //.byte 0,   2,  2,  4,  4,  6,  0,249,251,251,253,253 
      .byte 0, 254,254,252,252,250,  0,  6,  6,  4,  2,  0 

JumpAnimationRight:
    .byte 186, 187, 187, 188, 188, 188, 189, 189, 189, 190, 190, 191

JumpAnimationLeft:
    .byte 192, 193, 193, 194, 194, 194, 195, 195, 195, 196, 196, 197

start:
    lda #147
    jsr krljmp_CHROUT

    lda #<HELLOWORLD    // Grab Lo Byte of Hello World Location
    ldy #>HELLOWORLD    // Grab Hi Byte of Hello World Location
    jsr PRINT_LINE      // Print The Line

    lda #SPRITERAM + 8
    sta SPRITE0

    lda #SPRITERAM
    sta SPRITE0 + 1

    lda #3      // %0000 0011
    sta SPENA
//    sta YXPAND
//    sta XXPAND

    lda #2      // %0000 0010
    sta SPMC

    lda #60
    sta SP0X
    sta SP0X + 2

    lda #80
    sta SP0Y
    sta SP0Y + 2

    lda #0
    sta SP0COL

    lda #10
    sta SP0COL + 1

    lda #9
    sta SPMC0

    lda #5
    sta SPMC1

    lda #0
    sta FrameCounter
    sta Jumping

GameLooper:
    lda #240                // Scanline -> A
    cmp RASTER              // Compare A to current raster line
    bne GameLooper

    inc $D020

    inc FrameCounter
    lda FrameCounter
    cmp #32
    bne JumpingTest
    lda #0
    sta FrameCounter

JumpingTest:
    lda Jumping
    cmp #1
    bne KeyboardTest
    jsr JumpCycle

KeyboardTest:
    lda 197
    cmp #scanCode_A
    bne TestForDKey
    lda #255
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForDKey:
    cmp #scanCode_D
    bne TestForLKey
    lda #1
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForLKey:
    cmp #scanCode_L
    bne GameLooperEnd
    lda #1
    sta Jumping
    jmp GameLooperEnd

GameLooperEnd:
    dec $D020
    jmp GameLooper

// --------------------------------------------------------------
UpdateQuazzy:
    jsr CalculateSpriteFrame
    lda QuazzyDirection
    bmi GoingLeft
    lda Jumping
    cmp #1
    beq !+

    // Quazzy Going Right
    lda #QuazzyRight
    clc
    adc SpriteFrameCounter
    sta SPRITE0 + 1
    lda #QuazzyRight + 8
    clc
    adc SpriteFrameCounter
    sta SPRITE0

!:
    inc SP0X
    inc SP0X + 2
    jmp GameLooperEnd

GoingLeft:
    // Quazzy Going Left
    lda Jumping
    cmp #1
    beq !+

    lda #QuazzyLeft
    clc
    adc SpriteFrameCounter
    sta SPRITE0 + 1
    lda #QuazzyLeft + 8
    clc
    adc SpriteFrameCounter
    sta SPRITE0

!:
    dec SP0X
    dec SP0X + 2
    jmp GameLooperEnd

// ----------------------------------------------------------------

CalculateSpriteFrame:
    lda FrameCounter
    lsr  // /2
    lsr  // /4
    lsr  // /8
//    lsr  // /16
    sta SpriteFrameCounter
    rts

JumpCycle:
    lda FrameCounter
    beq !+
    cmp #8
    beq !+
    cmp #16
    beq !+
    cmp #24
    beq !+
    rts
!:
    inc JumpIndex
    ldx JumpIndex
    cpx #12
    beq !EndJump+
    lda SP0Y
    clc
    adc JumpArk,x 
    sta SP0Y
    sta SP0Y + 2

    lda QuazzyDirection
    bmi LeftAni
    lda JumpAnimationRight,x 
    jmp !+

LeftAni:
    lda JumpAnimationLeft,x 
!:
    sta SPRITE0 + 1
    clc
    adc #12
    sta SPRITE0
    rts

!EndJump:
    lda #0
    sta JumpIndex
    sta Jumping
    rts

HELLOWORLD:
    .text "HELLO, MY NAME IS QUAZZY OSBOURNE :)"  // the string to print
    .byte 00             // The terminator character

* = $2A80 "Sprite Date"
.import binary "sprites.bin"
.import binary "spritesJumping.bin"