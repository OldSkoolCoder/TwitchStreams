#importonce

#import "Constants.asm"
#import "libMacros.asm"

// Scroller Flag Direction
.const ScrollerSTOP     = %00000000             // No Scroll Direction
.const ScrollerLEFT     = %00000001             // Scroll Left, Character Go Right
.const ScrollerRIGHT    = %00000010             // Scroll Right, Character Go Left
.const ScrollerUP       = %00000100             // Scroll Up, Character Go Down
.const ScrollerDOWN     = %00001000             // Scroll Down, Character Go Up

.const ScreenRowTop     = 5                     // Top Row of Scrollable Screen
.const ScreenRowBottom  = 24                    // Bottom Row of Scrollable Screen

.namespace libScroller {
    
    .label Screen1Pointer   = $04               // Screen One ZP Pointer
    .label Screen2Pointer   = $06               // Screen Two ZP Pointer
    .label ColourPointer    = $08               // Solour Screen ZP Pointer

    .label CurrentScreenHi    = $10             // Current Screen HI Page Value

    ScrollDirectionRequested:   .byte 0         // Scroll Direction Requested
    ScrollDirectionMovement:    .byte 0         // Scroll Direction Actioning
    ScrollXFrameCounter:        .byte 0         // Current X Axis Scroll Value 0 -> 7
    ScrollYFrameCounter:        .byte 0         // Current Y Axis Scroll Value 0 -> 7

    MapTileCol:                 .byte 0         // Map Tile Column (0->20)
    TileColumn:                 .byte 0         // Tile Column Even/Odd = 0 / 1
    MaxMapTileCol:              .byte 0         // Last Tile Column#
    ScreenLHCol:                .byte 0

    ScreenRowLo:                                // Array Of Screen Lo Values
        .for (var row=0; row<25; row++) {
            .byte <(row * 40)
        }

    Screen1RowHi:                               // Array of Screen One Hi Values
        .for (var row=0; row<25; row++) {
            .byte >SCREENRAM + (row * 40)
        }
    
    Screen2RowHi:                               // Array of Screen Two Hi Values
        .for (var row=0; row<25; row++) {
            .byte >SCREEN2RAM + (row * 40)
        }

    ColourRowHi:                               // Array of Colour Screen Hi Values
        .for (var row=0; row<25; row++) {
            .byte >COLOURRAM + (row * 40)
        }

    // Buffers for the next Item on the shadow screen
    ColumnBuffer:                              // Buffer to load the NEXT Column
        .fill 25,0

    ColourColumnBuffer:                        // Buffer to load the NEXT Colour Column
        .fill 25,0

    RowBuffer:                                 // Buffer to load NEXT Row
        .fill 40,0

    ColourRowBuffer:                           // Buffer to load NEXT Colour Row
        .fill 40,0


// ******************************************************************************************************
    ProcessScroller:{
        lda ScrollDirectionRequested
        cmp #ScrollerSTOP               // Check for no direction desired
        bne !ScrollLeft+                // make sure we are correctly fixed

        lda ScrollDirectionMovement
        cmp #ScrollerLEFT               // Requested Scroll To The Left
        bne !FinishScrollRight+

        jsr ShiftScreenLeft             // Copy and Shift Left the Shadow Screen
        jsr EvaluateBufferLeft          // Evaluate the Column for Right hand Side
        jsr DrawBufferLeft              // Draw the Column Right hand Side Shadow Screen

        lda #ScrollerSTOP
        sta ScrollDirectionMovement
        rts

    !FinishScrollRight:
        lda ScrollDirectionMovement
        cmp #ScrollerLEFT               // Requested Scroll To The Left
        bne !FinishScrollUp+

        jsr ShiftScreenRight             // Copy and Shift Left the Shadow Screen
        jsr EvaluateBufferRight          // Evaluate the Column for Right hand Side
        jsr DrawBufferRight              // Draw the Column Right hand Side Shadow Screen

        lda #ScrollerSTOP
        sta ScrollDirectionMovement

!FinishScrollUp:
        rts

    !ScrollLeft:
        cmp #ScrollerLEFT               // Requested Scroll To The Left
        beq !LeftScroll+
        jmp !ScrollRight+

    !LeftScroll:
        // Frames 7,0,1,2
        // Frame 2 = Copy Screen To Shadow
        // Frame 1 = Evaluate New Column
        // Frame 0 = Draw New Column On Shadow
        // Frame 7 = Screen Switch and Colour Shift

        lda ScrollXFrameCounter         // Current X Axis Scroll Value
        cmp #2                          // Frame 2
        bne !LFrame1+
        jsr ShiftScreenLeft             // Copy and Shift Left the Shadow Screen
        jmp !LFrameIgnore+

    !LFrame1:
        cmp #1                          // Frame 1
        bne !LFrame0+
        jsr EvaluateBufferLeft          // Evaluate the Column for Right hand Side
        jmp !LFrameIgnore+

    !LFrame0:
        cmp #0                          // Frame Zero
        bne !LFrame7+
        jsr DrawBufferLeft              // Draw the Column Right hand Side Shadow Screen
        jmp !LFrameIgnore+

    !LFrame7:
        cmp #7                          // Frame 7 - Jump Frame
        bne !LFrameIgnore+

        jsr ScreenSwitcher              // Switch from Curent screen to Shadow Screen
        inc ScreenLHCol
        jsr ShiftColourLeft             // Shift Left The Colour Screen
        jsr DrawColourBufferLeft        // Draw New Colour Column
        //jmp !LFrameIgnore+

    !LFrameIgnore:                      // Any Other Frame
        lda ScrollDirectionRequested
        sta ScrollDirectionMovement
        jmp !XScrollNothing+

    !ScrollRight:
        cmp #ScrollerRIGHT              // Requested Scroll To The Right
        beq !RightScroll+
        jmp !ScrollDown+

    !RightScroll:
        // Frames 5,6,7,0
        // Frame 5 = Copy Screen To Shadow
        // Frame 6 = Evaluate New Column
        // Frame 7 = Draw New Column On Shadow
        // Frame 0 = Screen Switch and Colour Shift

        lda ScrollXFrameCounter             // Current X Axis Scroll Value
        cmp #5                              // Frame 5
        bne !RFrame6+
        jsr ShiftScreenRight                // Copy and Shift Right The Shadow Screen
        jmp !RFrameIgnore+

    !RFrame6:
        cmp #6                              // Frame 6
        bne !RFrame7+
        jsr EvaluateBufferRight             // Evaluate the Column for Left hand Side
        jmp !RFrameIgnore+

    !RFrame7:
        cmp #7                              // Frame 7
        bne !RFrame0+
        jsr DrawBufferRight                 // Draw the column Left hand side of Shadow Screen
        jmp !RFrameIgnore+

    !RFrame0:
        cmp #0                              // Frame 0 - Jump Frame
        bne !RFrameIgnore+

        jsr ScreenSwitcher                  // Switch from Current Screen to Shadow Screen
        dec ScreenLHCol
        jsr ShiftColourRight                // Shift Right the Colour Screen
        jsr DrawColourBufferRight           // Draw New Colour Column
        //jmp !RFrameIgnore+

    !RFrameIgnore:                          // Any Other Frame
        lda ScrollDirectionRequested
        sta ScrollDirectionMovement
        //jmp !ScrollNothing+

    !XScrollNothing:
        lda SCROLX                          // Get Current VIC Scroll X Value
        and #%11111000                      // Reset
        ora ScrollXFrameCounter             // Apply X Scroll Frame
        sta SCROLX                          // Set VIC Scroll X Value

        lda ScrollDirectionRequested
        cmp #ScrollerLEFT                   // Requested Left Scroll
        bne !HardwareScrollRight+

        ldx ScrollXFrameCounter             // Load Current X Frame Value
        dex                                 // Decrease by One
        txa
        and #%00000111                      // Remove anything over 7
        sta ScrollXFrameCounter             // Reapply
        jmp !HardwareScrollFinished+

!HardwareScrollRight:
        ldx ScrollXFrameCounter             // Load Current X Frame Value
        inx                                 // Increase by one
        txa
        and #%00000111                      // Remove anthing over 7
        sta ScrollXFrameCounter             // ReApply

!HardwareScrollFinished:
        rts


    !ScrollDown:
        cmp #ScrollerDOWN
        beq !DownScroll+
        jmp !ScrollUp+

    !DownScroll:
        // Frames 5,6,7,0
        // Frame 5 = Copy Screen To Shadow
        // Frame 6 = Evaluate New Column
        // Frame 7 = Draw New Column On Shadow
        // Frame 0 = Screen Switch and Colour Shift

        lda ScrollYFrameCounter
        cmp #4
        bne !DFrame5+
        jsr ShiftScreenDown
        jmp !DFrameIgnore+

    !DFrame5:
        cmp #5
        bne !DFrame6+
        jsr EvaluateBufferDown
        jmp !DFrameIgnore+

    !DFrame6:
        cmp #6
        bne !DFrame7+
        jsr DrawBufferDown
        jmp !DFrameIgnore+

    !DFrame7:
        cmp #0
        bne !DFrameIgnore+

        lda SCROLY
        and #%11111000
        ora ScrollYFrameCounter
        sta SCROLY

        jsr ScreenSwitcher
        jsr ShiftColourDown      
        jsr DrawColourBufferDown
        //jmp !DFrameIgnore+

    !DFrameIgnore:
        lda ScrollDirectionRequested
        sta ScrollDirectionMovement
        jmp !YScrollNothing+

    !ScrollUp:
        cmp #ScrollerUP
        beq !UpScroll+
        jmp !NothingScrolling+

    !UpScroll:
        // Frames 7,0,1,2
        // Frame 2 = Copy Screen To Shadow
        // Frame 1 = Evaluate New Column
        // Frame 0 = Draw New Column On Shadow
        // Frame 7 = Screen Switch and Colour Shift

        lda ScrollYFrameCounter
        cmp #3
        bne !UFrame1+
        jsr ShiftScreenUp
        jmp !UFrameIgnore+

    !UFrame1:
        cmp #2
        bne !UFrame0+
        jsr EvaluateBufferUp
        jmp !UFrameIgnore+

    !UFrame0:
        cmp #1
        bne !UFrame7+
        jsr DrawBufferUp
        jmp !UFrameIgnore+

    !UFrame7:
        cmp #7
        bne !UFrameIgnore+

        jsr ScreenSwitcher

        jsr ShiftColourUp
        jsr DrawColourBufferUp
        //jmp !UFrameIgnore+

    !UFrameIgnore:
        lda ScrollDirectionRequested
        sta ScrollDirectionMovement
        //jmp !YScrollNothing+

    !YScrollNothing:
        lda SCROLY
        and #%11111000
        ora ScrollYFrameCounter
        sta SCROLY

        lda ScrollYFrameCounter
        sta SCREEN2RAM
        sta SCREENRAM

        lda ScrollDirectionRequested
        cmp #ScrollerUP
        bne !HardwareScrollDown+

        ldx ScrollYFrameCounter
        dex
        txa
        and #%00000111
        sta ScrollYFrameCounter
        jmp !HardwareScrollFinished+

!HardwareScrollDown:
        ldx ScrollYFrameCounter
        inx
        txa
        and #%00000111
        sta ScrollYFrameCounter

!HardwareScrollFinished:
!NothingScrolling:
        rts
    }

    ScreenSwitcher:{
        // VICII Screen Switching
        lda VMCSB                   // Load Current Screen Video Address
        eor #%00010000              // Switch Screen Address $00 -> $01 -> $01
        sta VMCSB                   // Apply new Video screen address

        lda CurrentScreenHi         // Load Actual Video Screen Hi Address
        eor #%00000100              // Switch Screen Address $40 -> $44 -> $40
        sta CurrentScreenHi         // Apply new Address
        rts
    }

    ShiftScreenLeft:{
        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !CopyToScreen1+
        jmp !CopyToScreen2+

    !CopyToScreen1:
        // Copy Screen1 to Screen2
        mShiftCharactersLeft(SCREENRAM,SCREEN2RAM,ScreenRowTop,ScreenRowBottom)
        rts

    !CopyToScreen2:
        // Copy Screen2 to Screen1
        mShiftCharactersLeft(SCREEN2RAM,SCREENRAM,ScreenRowTop,ScreenRowBottom)
        rts
    }

    ShiftScreenRight:{
        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !CopyToScreen1+
        jmp !CopyToScreen2+

    !CopyToScreen1:
        // Copy Screen1 to Screen2
        mShiftCharactersRight(SCREENRAM,SCREEN2RAM,ScreenRowTop,ScreenRowBottom)
        rts

    !CopyToScreen2:
        // Copy Screen2 to Screen1
        mShiftCharactersRight(SCREEN2RAM,SCREENRAM,ScreenRowTop,ScreenRowBottom)
        rts
    }

    ShiftScreenDown:{
        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !CopyToScreen1+
        jmp !CopyToScreen2+

    !CopyToScreen1:
        // Copy Screen1 to Screen2
        mShiftCharactersDown(SCREENRAM,SCREEN2RAM,ScreenRowTop,ScreenRowBottom)
        rts

    !CopyToScreen2:
        // Copy Screen2 to Screen1
        mShiftCharactersDown(SCREEN2RAM,SCREENRAM,ScreenRowTop,ScreenRowBottom)
        rts
    }

    ShiftScreenUp:{
        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !CopyToScreen1+
        jmp !CopyToScreen2+

    !CopyToScreen1:
            // Copy Screen1 to Screen2
        mShiftCharactersUp(SCREENRAM,SCREEN2RAM,ScreenRowTop,ScreenRowBottom)
        rts

    !CopyToScreen2:
        // Copy Screen2 to Screen1
        mShiftCharactersUp(SCREEN2RAM,SCREENRAM,ScreenRowTop,ScreenRowBottom)
        rts
    }

    ShiftColourLeft:{
        // Copy ColourScreen to ColourScreen
        mShiftCharactersLeft(COLOURRAM,COLOURRAM,ScreenRowTop,ScreenRowBottom)
        rts
    }

    ShiftColourRight:{
        // Copy ColourScreen to ColourScreen
        mShiftCharactersRight(COLOURRAM,COLOURRAM,ScreenRowTop,ScreenRowBottom)
        rts
    }

    ShiftColourDown:{
        // Copy ColourScreen to ColourScreen
        mShiftCharactersDown(COLOURRAM,COLOURRAM,ScreenRowTop,ScreenRowBottom)
        rts
    }

    ShiftColourUp:{
        // Copy ColourScreen to ColourScreen
        mShiftCharactersUp(COLOURRAM,COLOURRAM,ScreenRowTop,ScreenRowBottom)
        rts
    }

    EvaluateBufferLeft:{

        jsr WorkOutMapCol

        lda #<MAP_1
        sta MapTile
        lda #>MAP_1
        sta MapTile + 1

        ldy #ScreenRowTop
    !MapColLooper:
        lda #0
        sta TileCharLookUp
        sta TileCharLookUp + 1

        lda MapTileCol
        clc
        adc #20
        tax
        lda MapTile: $C0DE,x

        sta TileCharLookUp
        asl TileCharLookUp
        rol TileCharLookUp + 1
        asl TileCharLookUp
        rol TileCharLookUp + 1

        clc
        lda #<MAP_TILES
        adc TileCharLookUp
        sta TileCharLookUp
        lda #>MAP_TILES
        adc TileCharLookUp + 1
        sta TileCharLookUp + 1

        ldx TileColumn
    !TileColLooper:
        lda TileCharLookUp: $C0DE,x
        sta ColumnBuffer,y
        sty LoadY
        tay
        lda CHAR_ColourS,y
        and #$0F
        ldy LoadY: #$FF
        sta ColourColumnBuffer,y

        inx
        inx
        iny
        cpx #4
        bcc !TileColLooper-

        clc
        lda MapTile
        adc MaxMapTileCol
        sta MapTile
        bcc !ByPassINC+
        inc MapTile+1

    !ByPassINC:
        cpy #ScreenRowBottom + 1
        bne !MapColLooper-
        rts
    }

    EvaluateBufferRight:{

        jsr WorkOutMapCol

        lda #<MAP_1
        sta MapTile
        lda #>MAP_1
        sta MapTile + 1

        ldy #ScreenRowTop
    !MapColLooper:
        lda #0
        sta TileCharLookUp
        sta TileCharLookUp + 1

        ldx MapTileCol
        lda MapTile: $C0DE,x

        sta TileCharLookUp
        asl TileCharLookUp
        rol TileCharLookUp + 1
        asl TileCharLookUp
        rol TileCharLookUp + 1

        clc
        lda #<MAP_TILES
        adc TileCharLookUp
        sta TileCharLookUp
        lda #>MAP_TILES
        adc TileCharLookUp + 1
        sta TileCharLookUp + 1

        ldx TileColumn
    !TileColLooper:
        lda TileCharLookUp: $C0DE,x
        sta ColumnBuffer,y
        sty LoadY
        tay
        lda CHAR_ColourS,y
        and #$0F
        ldy LoadY: #$FF
        sta ColourColumnBuffer,y

        inx
        inx
        iny
        cpx #4
        bcc !TileColLooper-

        clc
        lda MapTile
        adc MaxMapTileCol
        sta MapTile
        bcc !ByPassINC+
        inc MapTile+1

    !ByPassINC:
        cpy #ScreenRowBottom + 1
        bne !MapColLooper-
        rts
    }

    DrawBufferLeft:{

        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !Screen1+
        jmp !Screen2+

        !Screen1:
        .for (var row=ScreenRowTop; row<ScreenRowBottom+1; row++) {
            lda ColumnBuffer + row
            sta SCREEN2RAM + 39 + (row * 40)
        }
        rts

        !Screen2:
        .for (var row=ScreenRowTop; row<ScreenRowBottom+1; row++) {
            lda ColumnBuffer + row
            sta SCREENRAM + 39 + (row * 40)
        }
        rts
    }

    DrawBufferRight:{

        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !Screen1+
        jmp !Screen2+

        !Screen1:
        .for (var row=ScreenRowTop; row<ScreenRowBottom+1; row++) {
            lda ColumnBuffer + row
            sta SCREEN2RAM + (row * 40)
        }
        rts
        
        !Screen2:
        .for (var row=ScreenRowTop; row<ScreenRowBottom+1; row++) {
            lda ColumnBuffer + row
            sta SCREENRAM + (row * 40)
        }
        rts
    }

    DrawColourBufferLeft:{

        .for (var row=ScreenRowTop; row<ScreenRowBottom+1; row++) {
            lda ColourColumnBuffer + row
            sta COLOURRAM + 39 + (row * 40)
        }
        rts
    }

    DrawColourBufferRight:{

        .for (var row=ScreenRowTop; row<ScreenRowBottom+1; row++) {
            lda ColourColumnBuffer + row
            sta COLOURRAM + (row * 40)
        }
        rts
    }

    EvaluateBufferDown:{

        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !Screen1+
        jmp !Screen2+

        !Screen1:
        .for (var col=0; col<38+1; col++) {
            lda SCREENRAM + (ScreenRowBottom * 40) + col
            sta RowBuffer + col

            lda COLOURRAM + (ScreenRowBottom * 40) + col
            and #$0F
            sta ColourRowBuffer + col
        }
        rts
        !Screen2:
        .for (var col=0; col<38+1; col++) {
            lda SCREEN2RAM + (ScreenRowBottom * 40) + col
            sta RowBuffer + col

            lda COLOURRAM + (ScreenRowBottom * 40) + col
            and #$0F
            sta ColourRowBuffer + col
        }
        rts
    }

    EvaluateBufferUp:{

        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !Screen1+
        jmp !Screen2+

        !Screen1:
        .for (var col=0; col<38+1; col++) {
            lda SCREENRAM + (ScreenRowTop * 40) + col
            sta RowBuffer + col

            lda COLOURRAM + (ScreenRowTop * 40) + col
            and #$0F
            sta ColourRowBuffer + col
        }
        rts
        !Screen2:
        .for (var col=0; col<38+1; col++) {
            lda SCREEN2RAM + (ScreenRowTop * 40) + col
            sta RowBuffer + col

            lda COLOURRAM + (ScreenRowTop * 40) + col
            and #$0F
            sta ColourRowBuffer + col
        }
        rts
    }

    DrawBufferDown:{

        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !Screen1+
        jmp !Screen2+

        !Screen1:
        .for (var col=0; col<38+1; col++) {
            lda RowBuffer + col
            sta SCREEN2RAM + (ScreenRowTop * 40) + col
        }
        rts

        !Screen2:
        .for (var col=0; col<38+1; col++) {
            lda RowBuffer + col
            sta SCREENRAM + (ScreenRowTop * 40) + col
        }
        rts
    }

    DrawBufferUp:{

        lda CurrentScreenHi
        cmp #>SCREEN2RAM
        bne !Screen1+
        jmp !Screen2+

        !Screen1:
        .for (var col=0; col<38+1; col++) {
            lda RowBuffer + col
            sta SCREEN2RAM + ((ScreenRowBottom) * 40) + col
        }
        rts
        
        !Screen2:
        .for (var col=0; col<38+1; col++) {
            lda RowBuffer + col
            sta SCREENRAM + ((ScreenRowBottom) * 40) + col
        }
        rts
    }

    DrawColourBufferDown:{

        .for (var col=0; col<38+1; col++) {
            lda ColourRowBuffer + col
            sta COLOURRAM + (ScreenRowTop * 40) + col
        }
        rts
    }

    DrawColourBufferUp:{

        .for (var col=0; col<38+1; col++) {
            lda ColourRowBuffer + col
            sta COLOURRAM + ((ScreenRowBottom) * 40) + col
        }
        rts
    }

    WorkOutMapCol:
    {
        clc
        lda ScreenLHCol
        ror             // Divide By 2
        sta MapTileCol

        lda #0
        rol
        sta TileColumn
        rts

    }
}



