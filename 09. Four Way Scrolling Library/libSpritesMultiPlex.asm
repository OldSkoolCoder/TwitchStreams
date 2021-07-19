#import "Constants.asm"

    .const MaximumNoOfSprites = 18
    .const MAX_MUX_SPRITES = [MaximumNoOfSprites - 2]

* = $0A "Temp Storage" virtual

	TEMP1: .byte $00            // Temp variable used for Sort Routine
	TEMP2: .byte $00            // Temp variable used for Sort Routine

	VicSpriteIndex:             // Physical Sprite Current Index
		.byte $00

	SpriteIndex:                // Virtual Sprite Current index
		.byte $00
    
* = $10 "SpriteOrder Array" virtual 
	SpriteOrder:                // Virtual Sprite Order Sequence
		.fill MAX_MUX_SPRITES, 0

//--------------------------------------------------------------------------------------------------------
// Library of functions to apply to sprites for anything.

* =$0810 "MultiPlexor Library"
    .const libSprite_ONDEMAND = 1 
    .const libSprite_CONSTANT = 0 

    .const libSprite_INACTIVE = 0 
    .const libSprite_ACTIVE = 1 

    .const libSprite_ONCE = 0 
    .const libSprite_LOOPING = 1 

    // Multiplexor Constants
    .const PADDING = 5

.namespace libSprites 
{
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

    msmMultiplexorOn:   .byte $80               // Multiplexor enabled / disabled

    Enabled:    .fill MaximumNoOfSprites, 0    
    XFrac:      .fill MaximumNoOfSprites, 0    
    XLo:        .fill MaximumNoOfSprites, 0    
    XHi:        .fill MaximumNoOfSprites, 0    
    YFrac:      .fill MaximumNoOfSprites, 0    
    Y:          .fill MaximumNoOfSprites, $FF //60 + (i * 10)         // Initialise Y to stagger sprites
    Colour:     .fill MaximumNoOfSprites, 0    
    MColMode:   .fill MaximumNoOfSprites, 0    
    Frame:      .fill MaximumNoOfSprites, 0
    Priority:   .fill MaximumNoOfSprites, 0    
    Expand:     .fill MaximumNoOfSprites, 0     // 0 = Normal, 1 = X Big, 2 = Y Big, 3 = Both  

    .namespace Animation
    {
        Active:     .fill MaximumNoOfSprites, 0    

        FrameTableLo:       .fill MaximumNoOfSprites, 0    
        FrameTableHi:       .fill MaximumNoOfSprites, 0    
        CurrentFrameIndex:  .fill MaximumNoOfSprites, 0    
        Delay:              .fill MaximumNoOfSprites, 0    
        Speed:              .fill MaximumNoOfSprites, 0    
        Looping:            .fill MaximumNoOfSprites, 0    
        NumberOfFrames:     .fill MaximumNoOfSprites, 0
        OnDemand:           .fill MaximumNoOfSprites, 0    
//        Priority:   .fill MaximumNoOfSprites, 0    
    }
    Modified:   .fill MaximumNoOfSprites, 0    
    Linked:     .fill MaximumNoOfSprites, $80    

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
        // Data Destroyed : Acc, Y

        lda #$80
        jsr SetEnable
        rts
    }

    SpriteDisable:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc, Y
        
        lda #$00
        jsr SetEnable
        rts
    }

    SetEnable:
    {
        // Y = SpriteNumber, Acc = Disable (0) / Enabled (1)

        sta Enabled,y           // Store Enabled iinto the Sprite Array
        sta ZeroPageTemp

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified

        lda Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        tay                     // Linked Sprite Number
        lda ZeroPageTemp        // Load State
        jsr SetEnable           // Apply to Linked Sprite
    !NotLinked: 
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
        // Data Destroyed : Acc, Y
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
    GetY:
    {
        // Y = Sprite Number
        // Data Destroyed : Acc, Y
        // Output : Acc = Y Value

        lda Y,y                 // Store The Y location Value
        rts
    }

    SetY:
    {
        // Y = Sprite Number, Acc = Y Value
        // Data Destroyed : Acc, Y

        sta Y,y                 // Store The Y location Value

        lda #0
        sta YFrac,y             // Reset The Fraction

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified

        ldx Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        jsr CopyY               // Copy To Linked Sprite
    !NotLinked: 
        rts
    }

    AddToY:
    {
        // Y = SpriteNumber, Acc = Fraction, X = Y
        // Data Destroyed : Acc, Y

        clc
        adc YFrac,y             // Add Fraction
        sta YFrac,y 

        txa 
        adc Y,y                 // Add Y 
        sta Y,y 

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified

        ldx Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        jsr CopyY               // Copy To Linked Sprite
    !NotLinked: 
        rts
    }

    SubFromY:
    {
        // Y = SpriteNumber, Acc = Fraction, X = Y
        // Data Destroyed : Acc, Y

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

        ldx Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        jsr CopyY               // Copy To Linked Sprite
    !NotLinked: 
        rts

    }

    CopyY: 
    {
        // Y = Sprite Number From, X = Sprite Number to
        // Copy Y Value of Sprite Y into Sprite X
        // Data Destroyed : Acc, Y, X

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
    GetX:
    {
        // Y = Sprite Number
        // Data Destroyed : Acc, Y, X
        // Output : Acc = XHi Value, X = XLo

        lda XLo,y           // Store The XHi location Value
        tax
        lda XHi,y           // Store The XLo location Value
        rts
    }

    SetX:
    {
        // Y = Sprite Number, Acc = XHi Value, X = XLo
        // Data Destroyed : Acc, Y

        sta XHi,y           // Store The XHi location Value
        txa
        sta XLo,y           // Store The XLo location Value

        lda #0              
        sta XFrac,y         // Reset The Fraction

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified

        ldx Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        jsr CopyX               // Copy To Linked Sprite
    !NotLinked: 
        rts
    }

    AddToX:
    {
        // Y = SpriteNumber, Acc = Fraction, X = XLo
        // Data Destroyed : Acc, Y

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

        ldx Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        jsr CopyX               // Copy To Linked Sprite
    !NotLinked: 
        rts
    }

    SubFromX:
    {
        // Y = SpriteNumber, Acc = Fraction, X = XLo
        // Data Destroyed : Acc, Y

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

        ldx Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        jsr CopyX               // Copy To Linked Sprite
    !NotLinked: 
        rts

    }

    CopyX: 
    {
        // Y = Sprite Number From, X = Sprite Number to
        // Copy X Value of Sprite Y into Sprite X
        // Data Destroyed : Acc, Y, X

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

        lda XHi,y 
        beq !TurnOff+    // Hi Bit Not Required

        lda SpriteMask,y
        ora MSIGX           // Set Hi Bit
        jmp !Finished+

    !TurnOff:
        lda SpriteMask,y 
        eor #$FF
        and MSIGX           // Mask Out Hi Bit

    !Finished:
        sta MSIGX
        rts
    }

//*************************************************************************************************************
    SpriteMultiColour:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc, Y
        
        lda #1
        jsr SetMultiColour
        rts
    }

    SpriteStandardColour:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc, Y
        
        lda #0
        jsr SetMultiColour
        rts
    }

    SetMultiColour:
    {
        // Y = SpriteNumber, Acc = Disable (0) / Enabled (1)

        sta MColMode,y          // Store MultiColour into the Sprite Array
        sta ZeroPageTemp        // Temp Storage

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified

        lda Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        tay                     // Move To Linked Sprite
        lda ZeroPageTemp        // Load State
        jsr SetMultiColour      // Exectute again on linked sprite
    !NotLinked: 
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
        // Data Destroyed : Acc, Y
        
        lda #0
        jsr SetPriority
        rts
    }

    SpriteBehind:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc, Y
        
        lda #1
        jsr SetPriority
        rts
    }

    SetPriority:
    {
        // Y = SpriteNumber, Acc = InFront (0) / Behind (1)

        sta Priority,y          // Store Priority into the Sprite Array
        sta ZeroPageTemp        // Save State

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified

        lda Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        tay                     // Move To Linked Sprite
        lda ZeroPageTemp        // Load State
        jsr SetPriority         // Execute with linked sprite
    !NotLinked: 
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
        // Data Destroyed : Acc, Y
        
        lda #0
        jsr SetExpand
        rts
    }

    SpriteLargeX:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc, Y
        
        lda #1
        jsr SetExpand
        rts
    }

    SpriteLargeY:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc, Y
        
        lda #2
        jsr SetExpand
        rts
    }

    SpriteLarge:
    {
        // Inputs : Y = Sprite Number (0-7)
        // Data Destroyed : Acc, Y
        
        lda #3
        jsr SetExpand
        rts
    }

    SetExpand:
    {
        // Y = SpriteNumber, Acc = 0,1,2 or 3 (Normal, XBig, YBig, Both)

        sta Expand,y            // Store Expanded into the Sprite Array
        sta ZeroPageTemp

        lda #1                  // Load Modified Flag
        sta Modified,y          // Specified Sprite has been Modified

        lda Linked,y            // Load Linked Sprite Number
        bmi !NotLinked+         // Are we not linked?
        tay                     // Move To Linked Sprite
        lda ZeroPageTemp        // Load State
        jsr SetExpand           // Execute on linked sprite
    !NotLinked: 
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
    LinkSprites:
    {
        // Y = Orginal Sprite Number
        // X = Linked Sprite Number

        txa 
        sta Linked,y 
        rts
    }

    UnLinkSprites:
    {
        // Y = Orginal Sprite Number
        // Data Destroyed : Acc
        
        lda #$80
        sta Linked,y 
        rts
    }

//*************************************************************************************************************
    UpdateSprites:
        // Inputs : None
        // Data Destroyed : Acc, X, Y
        
    {
        jsr Sort

        lda #0 
        sta CurrentSprite           // Initialise Sprite Counter

        !UpdateSpriteLoop:
            ldy CurrentSprite       // Load Sprite Counter

            lda Modified,y          // Load sprite been modified Flag
            cmp #1                  // Has this sprite been modified
            bne !NoNeedToProcess+   // No, then no need to update

            cpy #2                  // After phyiscal sprites, only animate virtual sprites
            bcs !SkipAsLogicalSprite+

            jsr ApplyEnable         // Apply the Enabled Flag
            //jsr ApplyFrame          // Apply the Frame
            jsr ApplyY              // Apply where on the Y axis
            jsr ApplyX              // Apply where on the X Axis
            jsr ApplyMultiColour    // Set Multi Colour Mode
            jsr ApplyPriority       // Set Priority
            jsr ApplyExpand         // Set whether its big or not
            jsr ApplyColour         // Apply Colour

        !SkipAsLogicalSprite:
            lda Animation.OnDemand,y 
            beq !ConstantAnimation+ // Is this sprite animated ondemand?
            jsr ApplyAnimation      // Yes...
            jsr ApplyFrame          // Apply the Frame

        !ConstantAnimation:
            lda #0                  // Reset Modified Flag
            sta Modified,y

        !NoNeedToProcess:
            lda Animation.OnDemand,y
            bne !OnDemandAnimation+ // Is this Sprite animated constantly ?
            jsr ApplyAnimation      // Yes
            jsr ApplyFrame          // Apply the Frame

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
        sta AniA
        stx AniX
        sty AniY

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
        //sta SPRITE0,x                   // Store current sprite frame into the Sprite
        sta Frame,x                   // Store current sprite frame into the Sprite

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
        ldy AniY: #$FF
        ldx AniX: #$FF
        lda AniA: #$FF
        rts
    }

    MultiplexorInit:
    {
        sei

		lda #$7f
		sta $dc0d
		sta $dd0d

		lda #$35                // Bank Out The ROMS
		sta $01

		lda #$01
		sta IRQMSK


		lda #$00
		sta RASTER
		lda SCROLY
		and #$7f
		sta SCROLY
		lda #<IRQ
		sta $fffe	 
		lda #>IRQ
		sta $ffff
		asl VICIRQ
		cli

		//sprite setup
		lda #$FF            // Enable all the pysical Sprites
		sta SPENA
        
        ldy #MAX_MUX_SPRITES
    !ResetSort:
        tya
        sta SpriteOrder,y   // initalise all Y's
        dey 
        bpl !ResetSort-
        rts
    }

//*************************************************************************************************************
    EnableMUX:
    {
        // Data Destroyed : Acc

        lda #$00
        sta msmMultiplexorOn
        rts
    }

    DisableMUX:
    {
        // Data Destroyed : Acc
        
        lda #$80
        sta msmMultiplexorOn
        rts
    }


    *=* "IRQ"
IRQ: {
		pha
		txa 
		pha 
		tya 
		pha 

		inc $d020

        lda msmMultiplexorOn
        bpl LoopStart
        jmp !ExitRaster+

		LoopStart:
			lda VicSpriteIndex		    // load Real Sprite#
			and #$07				    // only 7 allowed
			cmp #6					    // higher than 6, reset to 0
			bcc !DoSprite+			    // lower than 6, right use this sprite
			lda #0					    // reset

		!DoSprite:
			sta VicSpriteIndex		    // store new real sprite#
			asl 					    // *2
			sta SelfMod + 1			    // update self mod jump vector
		SelfMod:
			jmp (VicSpriteTable)        // Jump to corresponding Physical Sprite Handler

		SpriteCollection:
			.for(var i=2; i<8; i++) 
			{
			Execute:
				ldx SpriteIndex			// load virtual sprite index
				lda SpriteOrder, x		// load virtual sprite offset
				tax

				lda Enabled+2,x		    // load sprite enabled value
				bpl !spritedisabled+	// disabled, then jump to disable routine
				
			!spriteok:
				lda Colour+2, x	        // load this virtual sprite colour
				sta SP0COL + i			// store in real sprite
                lda Frame+2, x          // load virtual sprite frame
				sta SPRITE0 + i			// store in real sprite

				lda XHi+2, x		    // get X MSB
				beq !nomsb+             // No MSB set
			!msb:
				lda MSIGX
				ora #[pow(2,i)]         // Set MSB
				sta MSIGX
				jmp !msbdone+
			!nomsb:
				lda MSIGX
				and #[255 - pow(2,i)]   // Clear MSB
				sta MSIGX
			!msbdone:

				lda MColMode+2, x		// Get Sprite MultiColour Mode Flag
				beq !nomc+
			!mc:
				lda SPMC
				ora #[pow(2,i)]         // Set MultCol
				sta SPMC
				jmp !mcdone+
			!nomc:
				lda SPMC
				and #[255 - pow(2,i)]   // Clear MultCol
				sta SPMC
			!mcdone:

				lda XLo+2, x
				sta SP0X + i * 2        // Store X Coord
				lda Y+2, x
				//sta $d001 + i * 2
				inc VicSpriteIndex      // Move to next Physical Sprite
				jmp !UseNextSprite+

			!spritedisabled:
				lda #0

			!UseNextSprite:
				sta SP0Y + i * 2        // Set Y Coord

			!spritedisabled:
				inc SpriteIndex
				ldx SpriteIndex
				cpx #MAX_MUX_SPRITES    // Done All Sprites
				bne !+                  // No
				jmp !Finish+            // Yes
			!:

				lda SpriteOrder, x      // Set up for next Raster Test
				tax

				lda Y+2, x              // Get Next Y
				sec 
				sbc #PADDING * 2        // sub padding
				cmp RASTER              // has Raster Arrived ?
				bcc !+
				jmp !nextRaster+
			!:
			}	
			jmp LoopStart

			!nextRaster:
				clc
				adc #PADDING
				sta RASTER
				jmp !ExitRaster+

		!Finish:
			lda #$00
			sta RASTER
			lda #$00
			sta VicSpriteIndex
			sta SpriteIndex

	!ExitRaster:
		dec $d020

		lda SCROLY
		and #$7f
		sta SCROLY
		asl VICIRQ
		pla
		tay 
		pla 
		tax
		pla
		rti
    }

    .align $100
	* = * "VicSpriteTable"
	VicSpriteTable:
		.word IRQ.SpriteCollection[0].Execute           // Sprite 2
		.word IRQ.SpriteCollection[1].Execute           // Sprite 3
		.word IRQ.SpriteCollection[2].Execute           // Sprite 4
		.word IRQ.SpriteCollection[3].Execute           // Sprite 5
		.word IRQ.SpriteCollection[4].Execute           // Sprite 6
		.word IRQ.SpriteCollection[5].Execute           // Sprite 7
		//.word IRQ.SpriteCollection[6].Execute
		//.word IRQ.SpriteCollection[7].Execute

    Sort: {	
            //inc $d020
                restart:
                    //SWIV adapted SORT
                    ldx #$00					// Start with First Sorted Sprite
                    txa 						// Clear Acc
            sortloop:       
                    ldy SpriteOrder,x 			// Load Virtual Sprite #
                    cmp Y,y 				    // Comp Acc with Virtual Sprite Y
                    beq noswap2 				// Are they the same ?
                    bcc noswap1 				// is the value smaller
                    stx TEMP1 					// Value must be bigger, Store current sort sprite index
                    sty TEMP2 					// store Virtual Sprite Index
                    lda Y,y 				    // Load Accumlator with Virual Sprite Y (New Sort Value)
                    ldy SpriteOrder - 1,x 		// promote sorted sprite 
                    sty SpriteOrder,x 
                    dex 						// move back one sorted sprite
                    beq swapdone 
            swaploop:       
                    ldy SpriteOrder - 1,x 
                    sty SpriteOrder,x 
                    cmp Y,y 
                    bcs swapdone 
                    dex 
                    bne swaploop 
            swapdone:       
                    ldy TEMP2 					// Load Virtual Sprite Index
                    sty SpriteOrder, x 			// Store in current sorted Sprite
                    ldx TEMP1 					// load back Sorted Sprite Index
                    ldy SpriteOrder, x 			// Load Virtual Sprite Index From Sorted
            noswap1:
                    lda Y, y 				    // Load Accumlator with Virual Sprite Y (New Sort Value)
            noswap2:
                    inx 						// Move to next Sorted Sprite
                    cpx #MAX_MUX_SPRITES		// Reach end of Sorted Sprites
                    bne sortloop 				// No ....

            //dec $d020
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

