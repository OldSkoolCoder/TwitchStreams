#import "Constants.asm"

BasicUpstart2(start)

.label Row = $02B0
.label Col = $02B1
.label TileNumber = $02B2
.label FrameCounter = $02A8
.label BellFrameCounter = $02B3
.label ScrollFrameCounter = $02B4
.label Direction = $02B5
.label TileFrameCounter = $02B6
.label FlameFrameCounter = $02B7
.label FlameTileCounter = $02B8
.label FullScreenScrollPerformed = $02B9

start:

    lda #0
    sta FullScreenScrollPerformed

    lda 1
    and #%11111110
    sta 1

    lda #BLACK
    sta EXTCOL
    lda #BLUE
    sta BGCOL0

    lda $DD00
    and #%11111100
    ora #%00000010      //<- your desired VIC bank value, Bank 1
    sta $DD00

    lda $D018
    and #%00000001
    ora #%00001000      //<- your desired CharMem bank value, Screem @ $4000, Character @ $6000
    sta $D018

    lda SCROLX
    and #%11110111
    ora #%00010000      // Set multicolour mode for characters
    sta SCROLX

    lda #BROWN 
    sta BGCOL1
    lda #GREY
    sta BGCOL2

    jsr DrawScreen          // Draw Map on the Screen

loop:
    sei
    lda #90                // Scanline -> A
    cmp RASTER              // Compare A to current raster line
    bne loop

    inc $D020

EndControls:
    inc FrameCounter        // increase frame counter
    lda FrameCounter
    and #127                // Only count 0 -> 127 (128 cycles)
    cmp #2                // 4 second frame counter (4 frames = .5 secs per frame)
    bne !ByPassReSet+
    lda #0                  // reset frame
    sta FrameCounter

    lda Direction
    beq !ByPassScroll+
    cmp #1
    bne DirectionLeft
    dec ScrollFrameCounter
    lda ScrollFrameCounter
    and #%00000111
    sta ScrollFrameCounter

    lda SCROLX
    and #%11111000
    ora ScrollFrameCounter
    sta SCROLX

    lda ScrollFrameCounter
    bne !ByPassScroll+
    jsr ScrollLeft
    dec FullScreenScrollPerformed
    jmp !ByPassScroll+

DirectionLeft:
    inc ScrollFrameCounter
    lda ScrollFrameCounter
    and #%00000111
    sta ScrollFrameCounter

    lda ScrollFrameCounter
    bne !ByPassScrollHere+
    jsr ScrollRight
    dec FullScreenScrollPerformed

!ByPassScrollHere:
    lda SCROLX
    and #%11111000
    ora ScrollFrameCounter
    sta SCROLX

!ByPassScroll:
    lda 197
    cmp #scanCode_A
    bne TestForDKey
    lda #1
    sta Direction
    jmp EndControls

TestForDKey:
    cmp #scanCode_D
    bne Nothing
    lda #2
    sta Direction
    jmp EndControls

Nothing:
    lda #0
    sta Direction

!ByPassReSet:
    lda FullScreenScrollPerformed
    bmi !ByPassAnimation+
    jsr Animate.GovernAnimationFrames

!ByPassAnimation:
    lda #0
    sta FullScreenScrollPerformed
    
    cli

    dec $D020
    jmp loop

CalculateBellFrame:
    lda FrameCounter
    lsr  // /2
    lsr  // /4
    lsr  // /8
    lsr  // 16
    lsr  // 32
    //sta BellFrameCounter
    rts

DrawScreen:
    lda #<SCREENRAM + (5*40) 
    sta Screen
    lda #>SCREENRAM + (5*40) 
    sta Screen + 1

    lda #<COLOURRAM + (5*40) 
    sta Colour
    lda #>COLOURRAM + (5*40) 
    sta Colour + 1

    lda #<MAP_1
    sta MapTile
    lda #>MAP_1
    sta MapTile + 1

    lda #0
    sta Row

DrawRowLoop:
    lda #0
    sta Col

DrawColumnLoop:
    ldy #0

    lda #0
    sta TileCharLookup
    sta TileCharLookup + 1

    lda MapTile: $DEAD      // Get Current Tile Number

    sta TileNumber
    sta TileCharLookup

    asl TileCharLookup           // * 2
    rol TileCharLookup + 1
    asl TileCharLookup
    rol TileCharLookup + 1      // * 4

    clc 
    lda #<MAP_TILES
    adc TileCharLookup
    sta TileCharLookup
    lda #>MAP_TILES
    adc TileCharLookup + 1
    sta TileCharLookup + 1

DrawTile:
    lda TileCharLookup: $B00B, y        // get Tile Character

    ldx TileLocationOffSet,y            // Character Offset.
    sta Screen: $BABE, x

    ldx TileNumber
    lda COLOUR_TILES, x                  // Colour information for tile

    ldx TileLocationOffSet, y
    sta Colour: $BEEF,x                 // Character Colour Ram

    iny
    cpy #$04
    bne DrawTile

    LIBMATH_ADD8BITTO16BIT_AV(MapTile,$01)

    LIBMATH_ADD8BITTO16BIT_AV(Screen,$02)

    LIBMATH_ADD8BITTO16BIT_AV(Colour,$02)

    inc Col 
    ldx Col 
    cpx #$14
    beq EndDrawColumnLoop
    jmp DrawColumnLoop

 EndDrawColumnLoop:  
    LIBMATH_ADD8BITTO16BIT_AV(Screen,$28)

    LIBMATH_ADD8BITTO16BIT_AV(Colour,$28)

    inc Row 
    ldx Row 
    cpx #$0A
    beq EndDrawRowLoop
    jmp DrawRowLoop

EndDrawRowLoop:
    rts

TileLocationOffSet:
    .byte 0, 1, 40, 41

AnimationOfBellArray:
// Animation Array Structure
// Animating 3 Frames Per Character

    .byte $04                   // No Of Chars
    .byte $04                   // No Of Frames
    .word BellTopLeft
    .word BellTopRight
    .word BellBottomLeft
    .word BellBottomRight

    // NoOfAnimationFrames
    // BufferChar#, FrameDelay#, Frame#1Char#, Frame#2Char#, Frame#3Char#
BellTopLeft:
    .word ($6000 + 115 * 8)
    .word ($6000 + 93 * 8)
    .word ($6000 + 100 * 8)
    .word ($6000 + 93 * 8)
    .word ($6000 + 104 * 8)

BellTopRight:
    .word ($6000 + 117 * 8)
    .word ($6000 + 96 * 8)
    .word ($6000 + 102 * 8)
    .word ($6000 + 96 * 8)
    .word ($6000 + 106 * 8)

BellBottomLeft:
    .word ($6000 + 116 * 8)
    .word ($6000 + 95 * 8)
    .word ($6000 + 101 * 8)
    .word ($6000 + 95 * 8)
    .word ($6000 + 105 * 8)

BellBottomRight:
    .word ($6000 + 119 * 8)
    .word ($6000 + 98 * 8)
    .word ($6000 + 103 * 8)
    .word ($6000 + 98 * 8)
    .word ($6000 + 107 * 8)

AnimationOfFlameArray:
// Animation Array Structure
// Animating 3 Frames Per Character

    .byte $01                   // No Of Chars
    .byte $04                   // No Of Frames
    .word Flame

    // NoOfAnimationFrames
    // BufferChar#, FrameDelay#, Frame#1Char#, Frame#2Char#, Frame#3Char#
Flame:
    .word ($6000 + 124 * 8)
    .word ($6000 + 120 * 8)
    .word ($6000 + 121 * 8)
    .word ($6000 + 122 * 8)
    .word ($6000 + 123 * 8)

* = $2000 "Map data"
    MAP_TILES:
        .import binary "Quasidemo - Tiles.bin"
    
    COLOUR_TILES:
        .import binary "Quasidemo - TileAttribs.bin"

    CHAR_ColourS:
        .import binary "Quasidemo - CharAttribs.bin"
    
    MAP_1:
        .import binary "Quasidemo - Map (20x11).bin"

* = $6000 "Chars data"
    CHARS:
        .import binary "Quasidemo - Chars.bin"

.macro LIBMATH_ADD8BITTO16BIT_AV(AddAddress,AddValue)
{
    clc
    lda AddAddress
    adc #AddValue
    sta AddAddress
    lda AddAddress + 1
    adc #$00
    sta AddAddress + 1
}

.macro DrawTile(TileLocationZeroPage, TileScreen, TileColour)
{
    ldy #0
!Tile:
    lda (TileLocationZeroPage), y        // get Tile Character

    ldx TileLocationOffSet,y            // Character Offset.
    sta TileScreen, x

    ldx TileNumber
    lda COLOUR_TILES, x                  // Colour information for tile

    ldx TileLocationOffSet, y
    sta TileColour,x                 // Character Colour Ram

    iny
    cpy #$04
    bne !Tile-
}

    // inc FrameCounter        // increase frame counter
    // lda FrameCounter
    // and #127                // Only count 0 -> 127 (128 cycles)
    //cmp #128                // 4 second frame counter (4 frames = .5 secs per frame)
    //bne AnimateBell
    //lda #0                  // reset frame
    // sta FrameCounter

// AnimateBell:
    //jsr CalculateBellFrame  // work out which frame the bell is currently on

    //cmp BellFrameCounter    // Bell Frame Counter same as before, no need to re-draw frame
    //bne DrawBellFrame
//     jmp EvaluateSpriteControl

// DrawBellFrame:
//     sta BellFrameCounter

//     lda #0
//     sta ZeroPageLow
//     sta ZeroPageLow + 1
    
//     ldx BellFrameCounter
//     lda BellAnimationTiles,x    // get bell tile frame for the frame counter
//     sta TileNumber

//     sta ZeroPageLow             // work out tile character offset
//     asl ZeroPageLow             // * 2
//     rol ZeroPageLow + 1
//     asl ZeroPageLow
//     rol ZeroPageLow + 1         // * 4

//     clc 
//     lda #<MAP_TILES             // add offset to Map Tiles Address Location
//     adc ZeroPageLow
//     sta ZeroPageLow
//     lda #>MAP_TILES
//     adc ZeroPageLow + 1
//     sta ZeroPageLow + 1

//     DrawTile(ZeroPageLow, $4162, $D962)     // Draw Tile

//     LIBMATH_ADD8BITTO16BIT_AV(ZeroPageLow,$04)  
//     inc TileNumber
//     DrawTile(ZeroPageLow, $4164, $D964)     // Draw Next Tile

// EvaluateSpriteControl:

* = * "Scroll Right"
ScrollRight:
{
    .label Rows         = ZeroPageParam1
    .label Cols         = ZeroPageParam2
    .label ScreenLoc    = ZeroPageLow
    .label ColourLoc    = ZeroPageLow2

    .label CharTransfer = ZeroPageParam3
    .label ColTransfer = ZeroPageParam3

    .label StartOfScrollingScreen = SCREENRAM + (5 * 40)
    .label StartOfScrollingColour = COLOURRAM + (5 * 40)

RowColumnCollection:
    .for (var row=0; row<20; row++)
    {
        lda StartOfScrollingScreen + (row * 40) + 39
        pha
        lda StartOfScrollingColour + (row * 40) + 39
        pha 

        .for (var col=38; col>=0; col--)
        {
            lda StartOfScrollingScreen + (row * 40) + col
            sta StartOfScrollingScreen + (row * 40) + col + 1
            
            lda StartOfScrollingColour + (row * 40) + col
            sta StartOfScrollingColour + (row * 40) + col + 1
        }

    //     ldy #38
    // !ColumnLooper:
    //     lda StartOfScrollingScreen + (row * 40),y
    //     iny
    //     sta StartOfScrollingScreen + (row * 40),y
    //     dey

    //     lda StartOfScrollingColour + (row * 40),y
    //     iny
    //     sta StartOfScrollingColour + (row * 40),y
    //     dey

    //     dey
    //     bpl !ColumnLooper-

        pla
        sta StartOfScrollingColour + (row * 40)
        pla
        sta StartOfScrollingScreen + (row * 40)
    }
    rts
}

* = * "Scroll Left"
ScrollLeft:
{
    .label Rows         = ZeroPageParam1
    .label Cols         = ZeroPageParam2
    .label ScreenLoc    = ZeroPageLow
    .label ColourLoc    = ZeroPageLow2

    .label CharTransfer = ZeroPageParam3
    .label ColTransfer = ZeroPageParam3

    .label StartOfScrollingScreen = SCREENRAM + (5 * 40)
    .label StartOfScrollingColour = COLOURRAM + (5 * 40)

    RowColumnCollection:
        .for (var row=0; row<20; row++)
        {
            lda StartOfScrollingScreen + (row * 40)
            pha
            lda StartOfScrollingColour + (row * 40)
            pha 

            .for (var col=0; col<39; col++)
            {
                lda StartOfScrollingScreen + (row * 40) + col + 1
                sta StartOfScrollingScreen + (row * 40) + col
                
                lda StartOfScrollingColour + (row * 40) + col + 1
                sta StartOfScrollingColour + (row * 40) + col
            }

            pla
            sta StartOfScrollingColour + (row * 40) + 39
            pla
            sta StartOfScrollingScreen + (row * 40) + 39
        }
        rts
}

* = * "Animate"
Animate:
{
    .label CharToRedefine= ZeroPageParam1
    .label FrameNumber   = ZeroPageParam2
    .label CurrentChar   = ZeroPageParam3

    .label ArrayZP       = ZeroPageParam4
    .label CharFrameArrayZP = ZeroPageParam6

    GovernAnimationFrames:
        inc BellFrameCounter
        lda BellFrameCounter
        and #127                // Only count 0 -> 127 (128 cycles)
        cmp #30                 // 1/4 Secs
        bne !ByPassBellReDefine+
        lda #0                  // reset frame
        sta BellFrameCounter
        inc TileFrameCounter
        lda TileFrameCounter
        cmp #4
        bne !JumpOverBellReset+
        lda #0
        sta TileFrameCounter

    !JumpOverBellReset:
        ldx #<AnimationOfBellArray
        ldy #>AnimationOfBellArray
        jsr Animate.ReDefineChar

    !ByPassBellReDefine:
        inc FlameFrameCounter
        lda FlameFrameCounter
        and #127                // Only count 0 -> 127 (128 cycles)
        cmp #07                 // 1/8 Secs
        bne !ByPassFlameReDefine+
        lda #0                  // reset frame
        sta FlameFrameCounter
        inc FlameTileCounter
        lda FlameTileCounter
        cmp #4
        bne !JumpOverFlameReset+
        lda #0
        sta FlameTileCounter

    !JumpOverFlameReset:
        ldx #<AnimationOfFlameArray
        ldy #>AnimationOfFlameArray
        jsr Animate.ReDefineChar

    !ByPassFlameReDefine:
        rts





    // Input Registers:
    // A = Frame Number
    // X = Array Lo
    // Y = Array Hi

    ReDefineChar:
        stx ArrayZP
        sty ArrayZP + 1

        sta FrameNumber
        ldy #0
        lda (ArrayZP),y         // No Of Chars To Redefine
        sta CharToRedefine

        ldx #0
    !CharRedefineLooper:
        inx
        txa
        asl
        tay
        dex

        lda (ArrayZP),y         // Lo Addres For Char
        sta CharFrameArrayZP
        iny
        lda (ArrayZP),y         // Lo Addres For Char
        sta CharFrameArrayZP + 1

        ldy #0
        lda (CharFrameArrayZP),y    // Lo Address Of Buffer Char
        sta BufferCharLocation
        iny
        lda (CharFrameArrayZP),y    // Lo Address Of Buffer Char
        sta BufferCharLocation + 1

        ldy FrameNumber
        iny
        tya
        asl
        tay

        lda (CharFrameArrayZP),y    // Lo Address Of Source Char
        sta SourceCharLocation
        iny
        lda (CharFrameArrayZP),y    // Lo Address Of Source Char
        sta SourceCharLocation + 1

        ldy #7
    !CharTransferLooper:
        lda SourceCharLocation: $C0DE,y
        sta BufferCharLocation: $C0DE,y 
        dey
        bpl !CharTransferLooper- 

        inx
        cpx CharToRedefine
        bne !CharRedefineLooper-
        rts
}


