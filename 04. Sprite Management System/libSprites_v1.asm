#import "Constants.asm"

//--------------------------------------------------------------------------------------------------------
// Library of functions to apply to sprites for anything.

.namespace libSprites 
{
    .const MaximumNoOfSprites = 8
    .label XPandX = %00000001 
    .label XPandY = %00000010

    SpriteMask:
        .byte %00000001
        .byte %00000010
        .byte %00000100
        .byte %00001000
        .byte %00010000
        .byte %00100000
        .byte %01000000
        .byte %10000000

    ModifiedSpriteMask:
    msmXChanged:        .byte %00000001         // X has Changed
    msmYChanged:        .byte %00000010         // Y has Changed
    msmColChanged:      .byte %00000100         // Colour Changed
    msmMColChanged:     .byte %00001000         // MultiColour Changed
    msmFrameChanged:    .byte %00010000         // Frame
    msmPriorityChanged: .byte %00100000         // Priority
    msmXPandChanged:    .byte %01000000         // Expanded
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
    Expand:     .fill MaximumNoOfSprites, 0     // 0 = Normal, 1 = X Big, 2 = Y Big, 3 = Both  

    Modified:   .fill MaximumNoOfSprites, 0    

    Workspace: .fill MaximumNoOfSprites, 0  

    CurrentSprite: .byte 0  

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

        lda #1 
        sta Modified,y 

        //jsr libSprites.ApplyEnable
        rts

    }

    ApplyEnable:
    {
        // Y = SpriteNumber
        ldx Enabled,y           // Load Enabled Flag From Array
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

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyFrame
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

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyY
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

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyY
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

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyY
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

        lda #1 
        sta Modified,x 
        //jsr libSprites.ApplyY
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

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyX
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

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyX
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

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyX
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

        lda #1 
        sta Modified,x 
        //jsr libSprites.ApplyX
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

    SetMulticolour:
    {
        // Y = SpriteNumber, Acc = Disable (0) / Enabled (1)

        sta MColMode,y           // Store Enabled iinto the Sprite Array

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyMultiColour
        rts

    }

    ApplyMultiColour:
    {
        // Y = SpriteNumber
        ldx MColMode,y           // Load Enabled Flag From Array
        lda SpriteMask,y        // Load Sprite Mask
        cpx #0                  // Disabled?
        beq !Disable+           // Yes

        ora SPMC               // Or Mask onto Sprite Enabled Byte
        jmp !Done+

    !Disable:
        eor #$FF                // Flit the Mask Bits 0->1 / 1->0
        and SPMC               // Mask Off the Sprite Bit

    !Done:
        sta SPMC               // Store result back into Sprite Enabled
        rts
    }

    SetPriority:
    {
        // Y = SpriteNumber, Acc = InFront (0) / Behind (1)

        sta Priority,y           // Store Enabled iinto the Sprite Array

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyPriority
        rts

    }

    ApplyPriority:
    {
        // Y = SpriteNumber
        ldx Priority,y           // Load Enabled Flag From Array
        lda SpriteMask,y        // Load Sprite Mask
        cpx #0                  // Disabled?
        beq !Disable+           // Yes

        ora SPBGPR               // Or Mask onto Sprite Enabled Byte
        jmp !Done+

    !Disable:
        eor #$FF                // Flit the Mask Bits 0->1 / 1->0
        and SPBGPR               // Mask Off the Sprite Bit

    !Done:
        sta SPBGPR               // Store result back into Sprite Enabled
        rts
    }

    SetExpand:
    {
        // Y = SpriteNumber, Acc = 0,1,2 or 3 (Normal, XBig, YBig, Both)

        sta Expand,y           // Store Enabled iinto the Sprite Array

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyExpand
        rts

    }

    ApplyExpand:
    {
        // Y = SpriteNumber,    00 = None, 01=XBig, 10=YBig, 11=Both
        lda SpriteMask,y        // Load Sprite Mask
        eor #$FF                // Flit the Mask Bits 0->1 / 1->0
        and XXPAND               // Mask Off the Sprite Bit
        sta XXPAND

        lda SpriteMask,y        // Load Sprite Mask
        eor #$FF                // Flit the Mask Bits 0->1 / 1->0
        and YXPAND               // Mask Off the Sprite Bit
        sta YXPAND

        lda Expand,y            // Load Enabled Flag From Array
        and #libSprites.XPandX
        cmp #libSprites.XPandX
        bne !XPandY+

        lda SpriteMask,y        // Load Sprite Mask
        ora XXPAND               // Or Mask onto Sprite Enabled Byte
        sta XXPAND

    !XPandY:
        lda Expand,y            // Load Enabled Flag From Array
        and #libSprites.XPandY
        cmp #libSprites.XPandY
        bne !Done+

        lda SpriteMask,y        // Load Sprite Mask
        ora YXPAND               // Or Mask onto Sprite Enabled Byte
        sta YXPAND

    !Done:
        rts
    }

    SetColour:
    {
        // Y = Sprite Number, Acc = Sprite Colour
        sta Colour,y             // Set Frame into Array

        lda #1 
        sta Modified,y 
        //jsr libSprites.ApplyColour
        rts
    }

    ApplyColour:
    {
        // Y = Sprite Number
        lda Colour,y             // Load Frame from array
        sta SP0COL,y           // Store in Sprite Pointer
        rts
    }

    UpdateSprites:
    {
        lda #0 
        sta CurrentSprite

        !UpdateSpriteLoop:
            ldy CurrentSprite

            lda Modified,y 
            cmp #1 
            bne !NoNeedToProcess+

            jsr ApplyEnable
            jsr ApplyFrame
            jsr ApplyY
            jsr ApplyX
            jsr ApplyMultiColour
            jsr ApplyPriority
            jsr ApplyExpand
            jsr ApplyColour

            lda #0 
            sta Modified,y

        !NoNeedToProcess:
            iny
            sty CurrentSprite
            cpy #MaximumNoOfSprites
            bcc !UpdateSpriteLoop-
        rts
    }
}

