// Constants For Sprites

.namespace workingSprites
{
    .const MaximumSprites = 8

    SpriteMaskNumber:
        .byte %00000001
        .byte %00000010
        .byte %00000100
        .byte %00001000
        .byte %00010000
        .byte %00100000
        .byte %01000000
        .byte %10000000

    Enabled:  .fill MaximumSprites, 0
    XFrac:    .fill MaximumSprites, 0
    XLo:      .fill MaximumSprites, 0
    XHi:      .fill MaximumSprites, 0
    YFrac:    .fill MaximumSprites, 0
    Y:        .fill MaximumSprites, 0
    Colour:   .fill MaximumSprites, 0
    MColour:  .fill MaximumSprites, 0
    Frame:    .fill MaximumSprites, 0
    Priority: .fill MaximumSprites, 0
    //Y:        .fill MaximumSprites, 0
    Temp:     .fill MaximumSprites, 0


    SetEnable:
    {
        // y = SpriteNumber, Acc = Disable = 0 / Enable = 1
        sta Enabled,y 
        tax
        jsr workingSprites.ApplyEnable
        rts
    }

    ApplyEnable: 
    {
        // y = SpriteNumber
        // x = 01 = Enable, 00 = Disable

        lda SpriteMaskNumber, y 
        cpx #0
        beq !Disabled+

        ora SPENA
        sta SPENA 
        jmp !Done+

    !Disabled:
        eor #$FF
        and SPENA 
        sta SPENA 

    !Done:
        rts
    }

    SetMColour:
    {
        // y = SpriteNumber, Acc = Disable = 0 / Enable = 1
        sta MColour,y 
        tax
        jsr workingSprites.ApplyMColour
        rts
    }

    ApplyMColour: 
    {
        // y = SpriteNumber
        // x = 01 = Enable, 00 = Disable

        lda SpriteMaskNumber, y 
        cpx #0
        beq !Disabled+

        ora SPMC
        sta SPMC 
        jmp !Done+

    !Disabled:
        eor #$FF
        and SPMC 
        sta SPMC 

    !Done:
        rts
    }

    SetColour:
    {
        // y = SpriteNumber, Acc = Colour
        sta Colour,y 
        jsr workingSprites.ApplyColour
        rts
    }

    ApplyColour: 
    {
        // y = SpriteNumber
        // Acc = Colour

        sta SP0COL, y 
        rts
    }

    setFrame:
    {
        // y = SpriteNumber, Acc = Frame
        sta Frame,y 
        jsr workingSprites.ApplyFrame
        rts
    }

    ApplyFrame: 
    {
        // y = SpriteNumber
        // Acc = Frame

        // clc
        // adc #BaseSpriteNumber

        sta SPRITE0, y 
        rts
    }

    SetX:
    {
        // Y = Sprite Number
        // Acc = Hi Number
        // X = Lo Number

        sta XHi,y 
        txa
        sta XLo,y 

        lda #0
        sta XFrac,y 

        jsr workingSprites.ApplyX
        rts
    }

    AddToX:
    {
        // Y = Sprite Number
        // Acc = Fraction
        // X = Lo Number

        clc
        adc XFrac,y 
        sta XFrac,y 

        txa 
        adc XLo,y 
        sta XLo,y 

        lda XHi,y 
        adc #0
        sta XHi,y 

        jsr workingSprites.ApplyX
        rts
    }

    SubFromX:
    {
        // Y = Sprite Number
        // Acc = Fraction
        // X = Lo Number

        sta Temp,y 
        sec
        lda XFrac,y 
        sbc Temp,y 
        sta XFrac,y 

        txa
        sta Temp,y 
        lda XLo,y
        sbc Temp,y 
        sta XLo,y 

        lda XHi,y 
        sbc #0
        sta XHi,y 

        jsr workingSprites.ApplyX
        rts
    }

    ApplyX:
    {
        // Y = Sprite Number
        lda XLo,y
        pha
        tya
        asl // * 2
        tax 
        pla
        sta SP0X,x 

        lda SpriteMaskNumber,y 
        eor #$FF
        and MSIGX
        sta MSIGX

        lda XHi,y 
        beq !Done+
        lda SpriteMaskNumber,Y
        ora MSIGX
        sta MSIGX

!Done:
        rts

    }

    SetY:
    {
        // Y = Sprite Number
        // Acc = Number

        sta Y,y 

        lda #0
        sta YFrac,y 

        jsr workingSprites.ApplyY
        rts
    }

    AddToY:
    {
        // Y = Sprite Number
        // Acc = Fraction
        // X = Number

        clc
        adc YFrac,y 
        sta YFrac,y 

        txa 
        adc Y,y 
        sta Y,y 

        jsr workingSprites.ApplyY
        rts
    }

    SubFromY:
    {
        // Y = Sprite Number
        // Acc = Fraction
        // X = Number

        sta Temp,y 
        sec
        lda YFrac,y 
        sbc Temp,y 
        sta YFrac,y 

        txa
        sta Temp,y 
        lda Y,y
        sbc Temp,y 
        sta Y,y 

        jsr workingSprites.ApplyY
        rts
    }

    ApplyY:
    {
        // Y = Sprite Number
        lda Y,y
        pha
        tya
        asl // * 2
        tax 
        pla
        sta SP0Y,x 

!Done:
        rts

    }
}