#import "Constants.asm"

//--------------------------------------------------------------------------------------------------------
// Library of functions to apply to sprites for anything.

    .const libSprite_ONDEMAND = 1 
    .const libSprite_CONSTANT = 0 

    .const libSprite_INACTIVE = 0 
    .const libSprite_ACTIVE = 1 

    .const libSprite_ONCE = 0 
    .const libSprite_LOOPING = 1 

.namespace libSprites 
{
    .const MaximumNoOfSprites = 8
    .const XPandX = %00000001 
    .const XPandY = %00000010

    SpriteMask:
        .byte %00000001                         // Sprite 0
        .byte %00000010                         // Sprite 1
        .byte %00000100                         // Sprite 2
        .byte %00001000                         // Sprite 3
        .byte %00010000                         // Sprite 4
        .byte %00100000                         // Sprite 5
        .byte %01000000                         // Sprite 6
        .byte %10000000                         // Sprite 7

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

    .namespace Animation
    {
        Active:     .fill MaximumNoOfSprites, 0    

        // QuazzyMCLeft: .byte 4,5,6,7
        // QuazzyHRLeft: .byte 12,13,14,15

        FrameTableLo:       .fill MaximumNoOfSprites, 0    
        FrameTableHi:       .fill MaximumNoOfSprites, 0    
        CurrentFrameIndex:  .fill MaximumNoOfSprites, 0    
        Delay:              .fill MaximumNoOfSprites, 0    
        Speed:              .fill MaximumNoOfSprites, 0    
        Looping:            .fill MaximumNoOfSprites, 0    
        NumberOfFrames:     .fill MaximumNoOfSprites, 0
        OnDemand:           .fill MaximumNoOfSprites, 0    
//        Priority:   .fill MaximumNoOfSprites, 0    
//        Priority:   .fill MaximumNoOfSprites, 0    
//        Priority:   .fill MaximumNoOfSprites, 0    
    }
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
    SpriteEnable:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc

        lda #1
        jsr SetEnable
        rts
    }

    SpriteDisable:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #0
        jsr SetEnable
        rts
    }

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
    SpriteMultiColour:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #1
        jsr SetMultiColour
        rts
    }

    SpriteStandardColour:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #0
        jsr SetMultiColour
        rts
    }

    SetMultiColour:
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
    SpriteInFront:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #0
        jsr SetPriority
        rts
    }

    SpriteBehind:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #1
        jsr SetPriority
        rts
    }

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
    SpriteSmall:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #0
        jsr SetExpand
        rts
    }

    SpriteLargeX:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #1
        jsr SetExpand
        rts
    }

    SpriteLargeY:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #2
        jsr SetExpand
        rts
    }

    SpriteLarge:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #3
        jsr SetExpand
        rts
    }

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
    SpriteColourBlack:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #BLACK
        jsr SetColour
        rts
    }

    SpriteColourWhite:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #WHITE
        jsr SetColour
        rts
    }

    SpriteColourRed:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #RED
        jsr SetColour
        rts
    }

    SpriteColourCyan:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #CYAN
        jsr SetColour
        rts
    }

    SpriteColourPurple:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #PURPLE
        jsr SetColour
        rts
    }

    SpriteColourGreen:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #GREEN
        jsr SetColour
        rts
    }

    SpriteColourBlue:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #BLUE
        jsr SetColour
        rts
    }

    SpriteColourYellow:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #YELLOW
        jsr SetColour
        rts
    }

    SpriteColourOrange:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #ORANGE
        jsr SetColour
        rts
    }

    SpriteColourBrown:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #BROWN
        jsr SetColour
        rts
    }

    SpriteColourLightRed:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #LIGHT_RED
        jsr SetColour
        rts
    }

    SpriteColourDarkGrey:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #DARK_GREY
        jsr SetColour
        rts
    }

    SpriteColourGrey:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #GREY
        jsr SetColour
        rts
    }

    SpriteColourLightGreen:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #LIGHT_GREEN
        jsr SetColour
        rts
    }

    SpriteColourLightBlue:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #LIGHT_BLUE
        jsr SetColour
        rts
    }

    SpriteColourLightGrey:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc
        
        lda #LIGHT_GREY
        jsr SetColour
        rts
    }

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
        // Inputs : None
        // Data Destroyed : Acc, X, Y
        
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

            lda Animation.OnDemand,y 
            beq !ConstantAnimation+ // Is this sprite animated ondemand?
            jsr ApplyAnimation      // Yes...
        !ConstantAnimation:

            lda #0                  // Reset Modified Flag
            sta Modified,y

        !NoNeedToProcess:
            lda Animation.OnDemand,y
            bne !OnDemandAnimation+ // Is this Sprite animated constantly ?
            jsr ApplyAnimation      // Yes
        !OnDemandAnimation:
            iny                     // Next Sprite
            sty CurrentSprite       // Store Away
            cpy #MaximumNoOfSprites // Have we reached the Maximum
            bcc !UpdateSpriteLoop-  // No, better do it again then
        rts
    }

//*************************************************************************************************************
    ApplyAnimation:
    {
        // Data Destroyed : Acc, X, Y
        // Inputs : Y = Sprite Number

        //          Save Registry States
        pha
        tya
        pha
        txa
        pha

        // swap Sprite Number from Y Register to X Register
        tya     // Sprite No was
        tax     // Sprite No is now
        // X = Sprite Number

        lda Animation.Active,x
        bne !AnimateSprite+             // IS the sprite currently been animated?
        jmp SkipAnimation               // No, Skip Animation System

        // Yes currently been animated.
    !AnimateSprite:

        // Load the frame table location
        lda Animation.FrameTableLo,x
        sta FrameTable
        lda Animation.FrameTableHi,x
        sta FrameTable + 1

        // Get Current Frame Number
        ldy Animation.CurrentFrameIndex,x
        lda FrameTable: $A55E,y         // Get Current Sprite Frame
        sta SPRITE0,x                   // Store current sprite frame into the Sprite

        dec Animation.Delay,x           // Decrease delay by one
        bne SkipAnimation               // Have we hit zero yet ?

        // Yes
        lda Animation.Speed,x
        sta Animation.Delay,x           // Reset delay back to speed value

        // increase frame index for next sprite frame
        inc Animation.CurrentFrameIndex,x
        lda Animation.CurrentFrameIndex,x
        cmp Animation.NumberOfFrames,x  // Did we hit the end of the animation?
        bcc SkipAnimation               // No

        // Yes
        lda Animation.Looping,x         // Is this a looping Animation?
        beq !StopAnimating+             // No

        // Yes
        lda #0
        sta Animation.CurrentFrameIndex,x
        jmp SkipAnimation

    !StopAnimating:
        lda #0                          // Turn Off Animation
        sta Animation.Active,x
    
    SkipAnimation:
        // Restore Register States
        pla
        tax
        pla
        tay
        pla
        rts
    }

}

//*************************************************************************************************************
.macro SetAnimation(SpriteNo,Active,FrameTableLo,FrameTableHi,NoOfFrames,Speed,Looping,OnDemand)
{
    ldy #SpriteNo                           // Which Sprite To Apply this too
    lda #Active                             // Is it Active
    sta libSprites.Animation.Active,y
    lda #FrameTableLo                       // FrameTable Location
    sta libSprites.Animation.FrameTableLo,y
    lda #FrameTableHi                       // FrameTable Location
    sta libSprites.Animation.FrameTableHi,y
    lda #Speed                              // How long before frame changes
    sta libSprites.Animation.Speed,y
    sta libSprites.Animation.Delay,y
    lda #Looping                            // Does the animation loop
    sta libSprites.Animation.Looping,y
    lda #0
    sta libSprites.Animation.CurrentFrameIndex,y 
    lda #NoOfFrames                         // How many frames in the animation
    sta libSprites.Animation.NumberOfFrames,y
    lda #OnDemand                           // Ondemad or Constant
    sta libSprites.Animation.OnDemand,y
}  

