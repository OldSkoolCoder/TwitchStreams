; 10 SYS (2080)

*=$0801

    BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $38, $30, $29, $00, $00, $00

*=$0820

VIC = $D000
SPRITE_ON = VIC + $15
SPRITE_0_X = VIC
SPRITE_0_Y = VIC + $01

SPRITE_1_X = VIC + $02
SPRITE_1_Y = VIC + $03

SPRITE_MSB = VIC + $10

SPRITE_ON_SPRITE = VIC + $1E
SPRITE_ON_4GROUND = VIC + $1F
 
SPRITE_0_COL = VIC + $27
SPRITE_0_POINTER = $07F8

SPRITE_1_COL = VIC + $28
SPRITE_1_POINTER = $07F9

; $02A7 -> $02FF IS NOT USED BY THE c64 EVER!!!!
XFrac = $02A7
XLO = $02A8
XHI = $02A9

YFrac = $02AA
Y = $02AB

KEY = $02AC
TEMP = $02AD

S2SCOLL = $02AE
S2FCOLL = $02AF
SpriteCollisionNumber = $02B0

; DECIMAL 10.1
;            ^ Fraction
;          ^ Whole Number

; BINARY %10101010 10101010
;                  ^ Fraction
;            ^ Whole Number

; 1/2 : 1/4 : 1/8 : 1/16 : 1/32 : 1/64 : 1/128 : 1/256
; %10000000 = 1/2
; %01000000 = 1/4
; %00010000 = 1/16

INCREMENT = %11000000

KEYBOARD = $C5

    lda SPRITE_ON
    ora #%00000111
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

    lda #145
    sta SPRITE_1_X
    lda #79
    sta SPRITE_1_Y

    lda #155
    sta SPRITE_1_X + 2
    lda #71
    sta SPRITE_1_Y + 2

    lda #192
    sta SPRITE_0_POINTER

    lda #196
    sta SPRITE_1_POINTER

    lda #196
    sta SPRITE_1_POINTER + 1

    lda #7
    sta SPRITE_0_COL

    lda #1
    sta SPRITE_1_COL

    lda VIC + $19
    ora #%00000110
    sta VIC + $19

ReadKeys

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

    bcs @ByPass
    dec Y

@ByPass
    lda #192
    sta SPRITE_0_POINTER
    jmp ModifySprite0

TestKeyDown
    cmp #12
    bne TestKeyLeft
    lda YFrac
    clc
    adc #INCREMENT
    sta YFrac
    bcc @ByPass
    inc Y

@ByPass
    lda #193
    sta SPRITE_0_POINTER
    jmp ModifySprite0

TestKeyLeft
    cmp #47
    bne TestKeyRight
    lda XFrac
    sec
    sbc #INCREMENT
    sta XFrac
    bcs @ByPass
    dec XLo
    bne @ByPass
    dec XHI

@ByPass
    lda #195
    sta SPRITE_0_POINTER
    jmp ModifySprite0


TestKeyRight
    cmp #44
    bne TestForKeyFire
    lda XFrac
    clc
    adc #INCREMENT
    sta XFrac
    bcc @ByPass
    inc XLo
    bne @ByPass
    inc XHI
@ByPass
    lda #194
    sta SPRITE_0_POINTER
    jmp ModifySprite0


TestForKeyFire
    cmp #20
    beq ColourChange
    jmp ReadKeys

ColourChange
    inc SPRITE_0_COL 

ModifySprite0

    lda XLO
    sta SPRITE_0_X

    lda SPRITE_MSB
    and #%11111110
    ora XHI
    sta SPRITE_MSB

    lda Y
    sta SPRITE_0_Y

    lda #$04
    sta ScrnLocal + 2
    lda #$00
    sta ScrnLocal + 1

    lda SPRITE_ON_4GROUND
    sta S2FCOLL
    ;lda SPRITE_ON_SPRITE
    ;sta S2SCOLL
    jsr PrintBinary

    ;lda S2SCOLL
    lda S2FCOLL
    lsr
    bcc @ByPass

    ;jsr SPR_COLL_DETECT
    ;stx $0410

    lda #1
    jmp AreWeUnderAttack
@ByPass
    lda #0

AreWeUnderAttack
    sta $D020
    jmp ReadKeys


PrintBinary
    sta TEMP
    ldy #7
Looper1
    lda #0
    lsr TEMP
    adc #$30
ScrnLocal
    sta $0400,y
    dey
    bpl Looper1
    rts


SPR_COLL_DETECT
    ldx #$07
    stx SpriteCollisionNumber
SPR_COLL_LOOP
    lda SpriteCollisionNumber
    asl
    tax
    lda SPRITE_0_Y,X                       ; Load Enemy Y position
    sec
    sbc SPRITE_0_Y                         ; Subtract Player Y position
    bpl CHECK_Y_NO_MINUS
    eor #$FF                            ; Invert result sign
CHECK_Y_NO_MINUS
    cmp #$15                            ; Check for enemy sprite distance Y
    bcs CHECK_PLR_NO_COLL
    lda SPRITE_0_X,X                       ; Load Enemy X position
    sec
    sbc SPRITE_0_X                         ; Subtract Player X position
    bpl CHECK_NO_MINUS
    eor #$FF                            ; Invert result sign
CHECK_NO_MINUS
    cmp #$17                            ; Check for enemy sprite distance X
    ldx SpriteCollisionNumber
;    lda SPRITE_MSB
;    eor SPRITEMSB,X
;    sbc #$00
    bcs CHECK_PLR_NO_COLL
    rts
CHECK_PLR_NO_COLL
    ldx SpriteCollisionNumber
    dex                                 ; Goes to next sprite/enemy
    stx SpriteCollisionNumber
    bne SPR_COLL_LOOP
    rts




*=$3000 ; 12288
incbin "3DMaze.spt", 1, 5 ,true
