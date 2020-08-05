//--------------------------------------------------------------------------------------------------------
// Library of functions to apply to sprites for anything.

.namespace libSprites 
{
    .const MaximumNoOfSprites = 8

    SpriteMask:
        .byte %00000001
        .byte %00000010
        .byte %00000100
        .byte %00001000
        .byte %00010000
        .byte %00100000
        .byte %01000000
        .byte %10000000

    Enabled:    .fill MaximumNoOfSprites, 0    
    XFrac:      .fill MaximumNoOfSprites, 0    
    XLo:        .fill MaximumNoOfSprites, 0    
    XHi:        .fill MaximumNoOfSprites, 0    
    YFrac:      .fill MaximumNoOfSprites, 0    
    Y:          .fill MaximumNoOfSprites, 0    
    Colour:     .fill MaximumNoOfSprites, 0    
    MColMode:   .fill MaximumNoOfSprites, 0    
    Frame:      .fill MaximumNoOfSprites, 0
    Priority:   .fill MaximumNoOfSprites, 0    

    Workspace: .fill MaximumNoOfSprites, 0    

    // Hi       Lo       Frac
    // 00000000 00000000 00000000
    //                <- ->
    //                   1111...1
    //                   ////   /
    //                   2481   2
    //                      6   5
    //                          6
    // Frac = 0.5 + .25 + .125 = 

    SetEnable:
    {
        // Y = SpriteNumber, Acc = Disable (0) / Enabled (1)

        sta Enabled,y           // Store Enabled iinto the Sprite Array

        jsr libSprites.ApplyEnable
        rts

    }

    ApplyEnable:
    {
        // Y = SpriteNumber
        lda Enabled,y           // Load Enabled Flag From Array
        tax

        lda SpriteMask,y        // Load Sprite Mask
        cpx #0                  // Disabled?
        beq !Disable+           // Yes

        ora SPENA               // Or Mask onto Sprite Enabled Byte
        jmp !Done+

    !Disable:
        eor #$FF                // Flit the Mask Bits 0->1 / 1->0
        and SPENA               // Mask Off the Sprite Bit

    !Done:
        sta SPENA               // Store result back into Sprite Enabled
        rts
    }

    SetFrame:
    {
        // Y = Sprite Number, Acc = Frame
        sta Frame,y             // Set Frame into Array

        jsr libSprites.ApplyFrame
        rts
    }

    ApplyFrame:
    {
        // Y = Sprite Number
        lda Frame,y             // Load Frame from array
        sta SPRITE0,y           // Store in Sprite Pointer
        rts
    }

    SetY:
    {
        // Y = Sprite Number, Acc = Y Value

        sta Y,y                 // Store The Y location Value

        lda #0
        sta YFrac,y             // Reset The Fraction

        jsr libSprites.ApplyY
        rts
    }

    AddToY:
    {
        // Y = SpriteNumber, Acc = Fraction, X = Y

        clc
        adc YFrac,y             // Add Fraction
        sta YFrac,y 

        txa 
        adc Y,y                 // Add Y 
        sta Y,y 

        jsr libSprites.ApplyY
        rts
    }

    SubFromY:
    {
        // Y = SpriteNumber, Acc = Fraction, X = Y

        sta Workspace,y         // Store Fraction Temporarily
        
        sec
        lda YFrac,y             // Load YFrac
        sbc Workspace,y         // Subtract Fraction
        sta YFrac,y 

        txa 
        sta Workspace,y         // Store Y Temporarily
        lda Y,y                 // Load Y
        sbc Workspace,y         // Subtract Y
        sta Y,y 

        jsr libSprites.ApplyY
        rts

    }

    CopyY: 
    {
        // Y = Sprite Number From, X = Sprite Number to
        // Copy Y Value of Sprite Y into Sprite X

        lda YFrac,y             // Load Y Sprite YFrac
        sta YFrac,x             // Store X Sprite YFrac

        lda Y,y                 // Load Y Sprite Y
        sta Y,x                 // Store X Sprite Y

        txa
        tay 
        jsr libSprites.ApplyY
        rts 

    }

    ApplyY:
    {
        // Y = SpriteNumber

        tya
        asl     // * 2
        tax  
        lda Y,y             // Load Y Value
        sta SP0Y,x          // Store To Sprite Y
        rts
    }

    SetX:
    {
        // Y = Sprite Number, Acc = XHi Value, X = XLo

        sta XHi,y           // Store The XHi location Value
        txa
        sta XLo,y           // Store The XLo location Value

        lda #0              
        sta XFrac,y         // Reset The Fraction

        jsr libSprites.ApplyX
        rts
    }

    AddToX:
    {
        // Y = SpriteNumber, Acc = Fraction, X = XLo

        clc
        adc XFrac,y        // Add Fraction
        sta XFrac,y 

        txa 
        adc XLo,y           // Add XLo
        sta XLo,y 

        lda XHi,y 
        adc #0              // Add XHi
        sta XHi,y 

        jsr libSprites.ApplyX
        rts
    }

    SubFromX:
    {
        // Y = SpriteNumber, Acc = Fraction, X = XLo

        sta Workspace,y     // Store Fraction Temporarily 
        
        sec
        lda XFrac,y         // Load XFrac
        sbc Workspace,y     // Subtract Fraction
        sta XFrac,y 

        txa 
        sta Workspace,y     // Store Y Temporarily
        lda XLo,y           // Load XLo
        sbc Workspace,y     // Subtract XLo
        sta XLo,y

        lda XHi,y           // Load XHi
        sbc #0              // Subtract XHi
        sta XHi,y 

        jsr libSprites.ApplyX
        rts

    }

    CopyX: 
    {
        // Y = Sprite Number From, X = Sprite Number to
        // Copy X Value of Sprite Y into Sprite X

        lda XFrac,y         // Load Y Sprite XFrac
        sta XFrac,x         // Store X Sprite XFrac

        lda XLo,y           // Load Y Sprite XLo
        sta XLo,x           // Store X Sprite XLo

        lda XHi,y           // Load Y Sprite XHi
        sta XHi,x           // Store X Sprite XHi

        txa
        tay 
        jsr libSprites.ApplyX
        rts 

    }

    ApplyX:
    {
        // Y = SpriteNumber

        tya
        asl     // * 2
        tax  
        lda XLo,y           // Load XLo Value
        sta SP0X,x          // Store To Sprite X

        lda SpriteMask,y 
        eor #$FF
        and MSIGX           // Mask Out Hi Bit
        sta MSIGX

        lda XHi,y 
        beq !DontBother+    // Hi Bit Not Required

        lda SpriteMask,y
        ora MSIGX           // Set Hi Bit
        sta MSIGX

    !DontBother:
        rts
    }


}

