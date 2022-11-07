BasicUpstart2(Start)

#import "Constants.asm"
#import "libKeyboard.asm"

* = * "Storage"
KeyPressed: .byte 0
LastKeyPressed: .byte 0

CurrentBand: .byte 0
SpriteMSBOn: .fill 8, pow(2,i)
SpriteMSBOff: .fill 8, 255 - pow(2,i)

RasterBands: .byte RasterBand1,RasterBand2,RasterBand3,RasterBand4,RasterBand5,RasterBand6,RasterBand7

SpriteDir: .fill 8,1

SpritesX:
    .fill 8, (i * 25) + 25
    .fill 8, (i * 25) + 30
    .fill 8, (i * 25) + 35
    .fill 8, (i * 25) + 40
    .fill 8, (i * 25) + 45
    .fill 8, (i * 25) + 50
    .fill 8, (i * 25) + 55

SpritesY:
    .fill 8, RasterBand1 + 6
    .fill 8, RasterBand2 + 6
    .fill 8, RasterBand3 + 6
    .fill 8, RasterBand4 + 6
    .fill 8, RasterBand5 + 6
    .fill 8, RasterBand6 + 6
    .fill 8, RasterBand7 + 6

SpriteMSB: .fill 8,0

* = * "Code"
Start:
    sei
    lda #BLACK
    sta $D021

    lda #$7f
    sta $dc0d
    sta $dd0d

    lda #$35
    sta $01

    lda #<IRQ
    //sta $0314       // IRQ Low Vector
    sta $FFFE
    lda #>IRQ
    //sta $0315       // IRQ Hi Vector
    sta $FFFF

    lda #%00000001
    sta $D01A       // IRQ Mask Control Byte
                    // Bit 0 = Raster IRQ Compare

    SetRasterLine(0)

    cli

    lda #%11111111
    sta SPENA
    lda #192
    sta SPRITE0
    sta SPRITE0 + 1
    sta SPRITE0 + 2 
    sta SPRITE0 + 3
    sta SPRITE0 + 4
    sta SPRITE0 + 5
    sta SPRITE0 + 6
    sta SPRITE0 + 7



!Looper:
    lda #230
!RasterLoop:
    cmp $D012
    bne !RasterLoop-

    CheckSpriteBoundary(0)
    CheckSpriteBoundary(1)
    CheckSpriteBoundary(2)
    CheckSpriteBoundary(3)
    CheckSpriteBoundary(4)
    CheckSpriteBoundary(5)
    CheckSpriteBoundary(6)

    MoveSpriteBands(0)
    MoveSpriteBands(1)
    MoveSpriteBands(2)
    MoveSpriteBands(3)
    MoveSpriteBands(4)
    MoveSpriteBands(5)
    MoveSpriteBands(6)
!Exit:
    jmp !Looper-


* = * "Irq Code"
IRQ:
    pha
    txa
    pha
    tya
    pha

    // lda #WHITE
    ldx $D012               // Raster Reg
// !Looper:
//     cpx $D012               // Raster Reg
//     beq !Looper-
//     sta $D020               // Border Colour
//     sta $D021               // BackGround Colour

//     lda #BLUE
//     ldx $D012               // Raster Reg
// !Looper:
//     cpx $D012               // Raster Reg
//     beq !Looper-
//     sta $D020               // Border Colour
//     sta $D021               // BackGround Colour

    HandleIRQRasterLine(RasterBand1, 0, 1, !CheckBand2+, !Exit+)
    // cpx #RasterBand1
    // bne !CheckBand2+
    // inc $D021
    // SetSpriteCoords(0)

    // SetRasterLine(1)
    // dec $D021
    // jmp !Exit+

!CheckBand2:
    HandleIRQRasterLine(RasterBand2, 1, 2, !CheckBand3+, !Exit+)
    // cpx #RasterBand2
    // bne !CheckBand3+
    // inc $D021
    // SetSpriteCoords(1)

    // SetRasterLine(2)
    // dec $D021
    // jmp !Exit+

!CheckBand3:
    HandleIRQRasterLine(RasterBand3, 2, 3, !CheckBand4+, !Exit+)
    // cpx #RasterBand3
    // bne !CheckBand4+
    // inc $D021
    // SetSpriteCoords(2)

    // SetRasterLine(3)
    // dec $D021
    // jmp !Exit+

!CheckBand4:
    HandleIRQRasterLine(RasterBand4, 3, 4, !CheckBand5+, !Exit+)
    // cpx #RasterBand4
    // bne !Exit+
    // inc $D021
    // SetSpriteCoords(3)

    // SetRasterLine(0)
    // dec $D021

!CheckBand5:
    HandleIRQRasterLine(RasterBand5, 4, 5, !CheckBand6+, !Exit+)

!CheckBand6:
    HandleIRQRasterLine(RasterBand6, 5, 6, !CheckBand7+, !Exit+)

!CheckBand7:
    HandleIRQRasterLine(RasterBand7, 6, 0, !Exit+, !Exit+)
!Exit:
    asl $D019
    pla
    tay
    pla
    tax
    pla

    rti

// Sprite = 192
* = $3000
.fill 64, 255


.macro SetSpriteCoords(RasterBand) 
{

    ldy #0
!Looper:
    tya
    asl
    tax
    lda SpritesX + (RasterBand * 8),y
    sta SP0X,x
    lda SpritesY + (RasterBand * 8),y
    sta SP0Y,x
    lda SpriteMSB + RasterBand
    sta MSIGX
    iny
    cpy #8
    bne !Looper-
}

.macro SetRasterLine(RasterBand) 
{
    lda $D011       // SCROLY, bit 7 = bit 8 of the Raster System, So Clearing it
    and #%01111111    
    sta $D011       // SCROLY

    ldy #RasterBand
    ldx RasterBands,y
    //dex
    //dex
    stx $D012       // RASTER = Raster Lo Value
}

.macro HandleIRQRasterLine(RasterLine, CurrentBand, NextBand, jmpByPass, jmpExit) {
    cpx #RasterLine
    bne jmpByPass
    //inc $D021
    SetSpriteCoords(CurrentBand)

    SetRasterLine(NextBand)
    //dec $D021
    jmp jmpExit
}

.macro CheckSpriteBoundary(RasterBand)
{
    lda SpritesX + (RasterBand * 8)
    cmp #140
    beq !Reversing+
    cmp #24
    bne !Exit+
!Reversing:
    lda SpriteDir + RasterBand
    eor #$FE
    sta SpriteDir + RasterBand
!Exit:
}

.macro MoveSpriteBands(RasterBand)
{
    lda SpriteDir + RasterBand
    bmi !GoingReverse+

    ldy #0      // Sprite
!InnerLooper:
    lda SpritesX + (RasterBand * 8),y
    clc
    adc #1
    sta SpritesX + (RasterBand * 8),y
    bcc !ByPassMSB+
    lda SpriteMSB + RasterBand
    ora SpriteMSBOn,y
    sta SpriteMSB + RasterBand

!ByPassMSB:
    iny
    cpy #8
    bne !InnerLooper-
    jmp !Exit+

!GoingReverse:
    ldy #0      // Sprite
!InnerLooper:
    lda SpritesX + (RasterBand * 8),y
    sec
    sbc #1
    sta SpritesX + (RasterBand * 8),y
    bcs !ByPassMSB+
    lda SpriteMSB + RasterBand
    and SpriteMSBOff,y
    sta SpriteMSB + RasterBand

!ByPassMSB:
    iny
    cpy #8
    bne !InnerLooper-

!Exit:
}


