#import "Constants.asm"

//====================================================================
BasicUpstart2(start)

.label PRINT_LINE   = $AB1E
.label QuazzyDirection = $02A7
.label FrameCounter = $02A8
.label SpriteFrameCounter = $02A9

.label QuazzyRight = 170
.label QuazzyLeft = 174

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
    sta SP0Y
    sta SP0X + 2
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

GameLooper:
    lda #240                // Scanline -> A
    cmp RASTER              // Compare A to current raster line
    bne GameLooper

    inc FrameCounter
    lda FrameCounter
    cmp #32
    bne KeyboardTest
    lda #0
    sta FrameCounter

KeyboardTest:
    lda 197
    cmp #scanCode_A
    bne TestForDKey
    lda #255
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForDKey:
    cmp #scanCode_D
    bne GameLooper
    lda #1
    sta QuazzyDirection
    jmp UpdateQuazzy

// --------------------------------------------------------------
UpdateQuazzy:
    jsr CalculateSpriteFrame
    lda QuazzyDirection
    bmi GoingLeft

    // Quazzy Going Right
    lda #QuazzyRight
    clc
    adc SpriteFrameCounter
    sta SPRITE0 + 1
    lda #QuazzyRight + 8
    clc
    adc SpriteFrameCounter
    sta SPRITE0

    inc SP0X
    inc SP0X + 2
    jmp GameLooper

GoingLeft:
    // Quazzy Going Left
    lda #QuazzyLeft
    clc
    adc SpriteFrameCounter
    sta SPRITE0 + 1
    lda #QuazzyLeft + 8
    clc
    adc SpriteFrameCounter
    sta SPRITE0

    dec SP0X
    dec SP0X + 2
    jmp GameLooper

// ----------------------------------------------------------------

CalculateSpriteFrame:
    lda FrameCounter
    lsr  // /2
    lsr  // /4
    lsr  // /8
//    lsr  // /16
    sta SpriteFrameCounter
    rts

HELLOWORLD:
    .text "HELLO WORLD"  // the string to print
    .byte 00             // The terminator character

* = $2A80 "Sprite Date"
.import binary "sprites.bin"
