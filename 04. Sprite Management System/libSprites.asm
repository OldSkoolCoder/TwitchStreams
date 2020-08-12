#import "Constants.asm"

//--------------------------------------------------------------------------------------------------------
// Library of functions to apply to sprites for anything.

.namespace libSprites 
{
    .const MaximumNoOfSprites = 8
    .const XPandX = %00000001 
    .const XPandY = %00000010

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

//*************************************************************************************************************
    SetEnable:
    {
        // Y = SpriteNumber, Acc = Disable (0) / Enabled (1)

        sta Enabled,y           // Store Enabled iinto the Sprite Array

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

//*************************************************************************************************************
    SetFrame:
    {
        // Y = Sprite Number, Acc = Frame
        sta Frame,y             // Set Frame into Array

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
        rts
    }

    ApplyFrame:
    {
        // Y = Sprite Number
        lda Frame,y             // Load Frame from array
        sta SPRITE0,y           // Store in Sprite Pointer
        rts
    }

//*************************************************************************************************************
    SetY:
    {
        // Y = Sprite Number, Acc = Y Value

        sta Y,y                 // Store The Y location Value

        lda #0
        sta YFrac,y             // Reset The Fraction

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

//*************************************************************************************************************
    SetX:
    {
        // Y = Sprite Number, Acc = XHi Value, X = XLo

        sta XHi,y           // Store The XHi location Value
        txa
        sta XLo,y           // Store The XLo location Value

        lda #0              
        sta XFrac,y         // Reset The Fraction

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
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

//*************************************************************************************************************
    SetMulticolour:
    {
        // Y = SpriteNumber, Acc = Disable (0) / Enabled (1)

        sta MColMode,y          // Store MultiColour into the Sprite Array

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
        rts

    }

    ApplyMultiColour:
    {
        // Y = SpriteNumber
        ldx MColMode,y         // Load MultiColour Flag From Array
        lda SpriteMask,y       // Load Sprite Mask
        cpx #0                 // Disabled?
        beq !Disable+          // Yes

        ora SPMC               // Or Mask onto Sprite MultiColour Byte
        jmp !Done+

    !Disable:
        eor #$FF               // Filter the Mask Bits 0->1 / 1->0
        and SPMC               // Mask Off the Sprite Bit

    !Done:
        sta SPMC               // Store result back into Sprite MultiColour
        rts
    }

//*************************************************************************************************************
    SetPriority:
    {
        // Y = SpriteNumber, Acc = InFront (0) / Behind (1)

        sta Priority,y          // Store Priority into the Sprite Array

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
        rts

    }

    ApplyPriority:
    {
        // Y = SpriteNumber
        ldx Priority,y          // Load Priority Flag From Array
        lda SpriteMask,y        // Load Sprite Mask
        cpx #0                  // Infront Of Screen?
        beq !InFrontOfScreen+   // Yes

        ora SPBGPR              // Or Mask onto Sprite Priority Byte
        jmp !Done+

    !InFrontOfScreen:
        eor #$FF                // Flit the Mask Bits 0->1 / 1->0
        and SPBGPR              // Mask Off the Sprite Bit

    !Done:
        sta SPBGPR              // Store result back into Sprite Priority
        rts
    }

//*************************************************************************************************************
    SetExpand:
    {
        // Y = SpriteNumber, Acc = 0,1,2 or 3 (Normal, XBig, YBig, Both)

        sta Expand,y            // Store Expanded into the Sprite Array

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
        rts

    }

    ApplyExpand:
    {
        // Y = SpriteNumber,    00 = None, 01=XBig, 10=YBig, 11=Both
        lda SpriteMask,y        // Load Sprite Mask
        eor #$FF                // Filter the Mask Bits 0->1 / 1->0
        and XXPAND              // Mask Off the Sprite Bit
        sta XXPAND

        lda SpriteMask,y        // Load Sprite Mask
        eor #$FF                // Filter the Mask Bits 0->1 / 1->0
        and YXPAND              // Mask Off the Sprite Bit
        sta YXPAND

        lda Expand,y            // Load Expand Flag From Array
        and #XPandX             // And with X Xpand Flag
        cmp #XPandX             // Are we left with Xpand Flag
        bne !XPandY+            // no 

        lda SpriteMask,y        // Load Sprite Mask
        ora XXPAND              // Or Mask onto Sprite Expand X Byte
        sta XXPAND

    !XPandY:
        lda Expand,y            // Load Expand Flag From Array
        and #XPandY             // And with Y Xpand Flag
        cmp #XPandY             // Are we left with Xpand Flag
        bne !Done+              // no

        lda SpriteMask,y        // Load Sprite Mask
        ora YXPAND              // Or Mask onto Sprite Expand Y Byte
        sta YXPAND

    !Done:
        rts
    }

//*************************************************************************************************************
    SetColour:
    {
        // Y = Sprite Number, Acc = Sprite Colour
        sta Colour,y            // Set Colour into Array

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified
        rts
    }

    ApplyColour:
    {
        // Y = Sprite Number
        lda Colour,y            // Load Colour from array
        sta SP0COL,y            // Store in Sprite Colour
        rts
    }

//*************************************************************************************************************
    UpdateSprites:
    {
        lda #0 
        sta CurrentSprite           // Initialise Sprite Counter

        !UpdateSpriteLoop:
            ldy CurrentSprite       // Load Sprite Counter

            lda Modified,y          // Load sprite been modified Flag
            cmp #1                  // Has this sprite been modified
            bne !NoNeedToProcess+   // No, then no need to update

            jsr ApplyEnable         // Apply the Enabled Flag
            jsr ApplyFrame          // Apply the Frame
            jsr ApplyY              // Apply where on the Y axis
            jsr ApplyX              // Apply where on the X Axis
            jsr ApplyMultiColour    // Set Multi Colour Mode
            jsr ApplyPriority       // Set Priority
            jsr ApplyExpand         // Set whether its big or not
            jsr ApplyColour         // Apply Colour

            lda #0                  // Reset Modified Flag
            sta Modified,y

        !NoNeedToProcess:
            iny                     // Next Sprite
            sty CurrentSprite       // Store Away
            cpy #MaximumNoOfSprites // Have we reached the Maximum
            bcc !UpdateSpriteLoop-  // No, better do it again then
        rts
    }
}

