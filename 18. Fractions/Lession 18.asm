BasicUpstart2(Start)

*=$0820

.label VIC = $D000
.label SPRITE_ON = VIC + $15
.label SPRITE_0_X = VIC
.label SPRITE_0_Y = VIC + $01
.label SPRITE_MSB = VIC + $10
.label SPRITE_0_COL = VIC + $27
.label SPRITE_0_POINTER = $07F8

// $02A7 -> $02FF IS NOT USED BY THE c64 EVER!!!!
.label XFrac = $02A7
.label XLO = $02A8
.label XHI = $02A9

.label YFrac = $02AA
.label Y = $02AB

.label KEY = $02AC

// DECIMAL 10.1
//            ^ Fraction
//          ^ Whole Number

// BINARY %10101010 10101010
//                  ^ Fraction
//            ^ Whole Number

// 00000001 10000000  = 1 1/2
//        ^ = 1
//          ^ = 1/2

// 10000000 + 10000000 = 1 00000000

// 1/2 : 1/4 : 1/8 : 1/16 : 1/32 : 1/64 : 1/128 : 1/256
// %10000000 = 1/2
// %01000000 = 1/4
// %00010000 = 1/16


// Base 10 0.164 = 
// %11000000 = 3/4

.label INCREMENT = %11000000   // 1

.label KEYBOARD = $C5

Start:
    lda SPRITE_ON
    ora #1
    sta SPRITE_ON

    lda #0
    sta XFrac
    sta YFrac
    sta XHI
    lda #60
    sta XLO
    sta Y

    lda XLO
    sta SPRITE_0_X
    lda Y
    sta SPRITE_0_Y

    lda #192
    sta SPRITE_0_POINTER

    lda #7
    sta SPRITE_0_COL

ReadKeys:

    lda #$fb
    cmp $D012
    bne ReadKeys

    lda KEYBOARD
    cmp #64
    beq ReadKeys
    sta KEY

    cmp #10
    bne TestKeyDown
    lda YFrac
    sec
    sbc #INCREMENT
    sta YFrac

    bcs !ByPass+
    dec Y

!ByPass:
    lda #192
    sta SPRITE_0_POINTER
    jmp ModifySprite0

TestKeyDown:
    cmp #12
    bne TestKeyLeft
    lda YFrac
    clc
    adc #INCREMENT
    sta YFrac
    bcc !ByPass+
    inc Y

!ByPass:
    lda #193
    sta SPRITE_0_POINTER
    jmp ModifySprite0

TestKeyLeft:
    cmp #47
    bne TestKeyRight
    lda XFrac
    sec
    sbc #INCREMENT
    sta XFrac
    bcs !ByPass+
    dec XLO
    bne !ByPass+
    dec XHI

!ByPass:
    lda #195
    sta SPRITE_0_POINTER
    jmp ModifySprite0


TestKeyRight:
    cmp #44
    bne TestForKeyFire
    lda XFrac
    clc
    adc #INCREMENT
    sta XFrac
    bcc !ByPass+
    inc XLO
    bne !ByPass+
    inc XHI
!ByPass:
    lda #194
    sta SPRITE_0_POINTER
    jmp ModifySprite0


TestForKeyFire:
    cmp #20
    beq ColourChange
    jmp ReadKeys

ColourChange:
    inc SPRITE_0_COL 

ModifySprite0:

    lda XLO
    sta SPRITE_0_X

    lda SPRITE_MSB
    and #%11111110
    ora XHI
    sta SPRITE_MSB

    lda Y
    sta SPRITE_0_Y
    jmp ReadKeys





*=$3000 // 12288
//incbin "3DMaze.spt", 1, 4 ,true
.import binary "Sprites.bin"

