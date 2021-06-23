#import "Constants.asm"
BasicUpstart2(start)

// Quazzy Movement
.label QuazzyDirection = $02A7
.label SpriteFrameCounter = $02A8
.label QuazzyFrameCounter = $02A9
.label Jumping = $02AA
.label JumpIndex = $02AB
.label JoystickState = $02AC

.label QuazzyRight = SPRITERAM + 0 //170
.label QuazzyLeft = SPRITERAM + 4 //174
.label QuazzyJumpRight = SPRITERAM + 16 //186
.label QuazzyJumpLeft = SPRITERAM + 20 //190
.label EsmeraldaRightBase = SPRITERAM + 32 //206
.label EsmeraldaLeftBase = SPRITERAM + 36 //202

JumpArk:
    //.byte 0, 2, 4, 8, 12, 18, 18, 12,  8,  4,  2,  0
    //.byte 0,   2,  2,  4,  4,  6,  0,249,251,251,253,253 
      .byte 0, 254,254,252,252,250,  0,  6,  6,  4,  2,  0 

JumpAnimationRight:
    //.byte 186, 187, 187, 188, 188, 188, 189, 189, 189, 190, 190, 191
    //.byte 186, 186, 186, 187, 187, 187, 188, 188, 188, 189, 189, 189
    .byte SPRITERAM + 16, SPRITERAM + 16, SPRITERAM + 16, SPRITERAM + 17
    .byte SPRITERAM + 17, SPRITERAM + 17, SPRITERAM + 18, SPRITERAM + 18
    .byte SPRITERAM + 18, SPRITERAM + 19, SPRITERAM + 19, SPRITERAM + 19

JumpAnimationLeft:
    //.byte 192, 193, 193, 194, 194, 194, 195, 195, 195, 196, 196, 197
    //.byte 190, 190, 190, 191, 191, 191, 192, 192, 192, 193, 193, 193
    .byte SPRITERAM + 20, SPRITERAM + 20, SPRITERAM + 20, SPRITERAM + 21
    .byte SPRITERAM + 21, SPRITERAM + 21, SPRITERAM + 22, SPRITERAM + 22
    .byte SPRITERAM + 22, SPRITERAM + 23, SPRITERAM + 23, SPRITERAM + 23



.label Row = $02B0
.label Col = $02B1
.label TileNumber = $02B2
.label BellScrollingFrameCounter = $02B3
.label ScrollScrollingFrameCounter = $02B4
.label Direction = $02B5
.label TileScrollingFrameCounter = $02B6
.label FlameScrollingFrameCounter = $02B7
.label FlameTileCounter = $02B8
.label FullScreenScrollPerformed = $02B9
.label ScrollingFrameCounter = $02BA

start:

    // Set Up VIC Chip to move Screen to $4000
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

    // Draw First Frame Of the Map
    jsr DrawScreen          // Draw Map on the Screen

    // Quazzy
    lda #SPRITERAM + 8
    ldy #0
    jsr workingSprites.setFrame

    lda #SPRITERAM
    iny
    jsr workingSprites.setFrame

    // Jill
    iny
    lda #SPRITERAM + 40
    jsr workingSprites.setFrame

    iny
    lda #SPRITERAM + 32
    jsr workingSprites.setFrame

    // Enabling the First 4 Sprites
    lda #15      // %0000 1111
    sta SPENA

    // Setting Sprite 1 and 3 to be MultiColour
    lda #%00001010
    sta SPMC

    lda #%00001100
    sta SPBGPR

    // Setting X Position Of Quazzy
    lda #0          // XHi
    ldx #80         // XLo
    ldy #0          // SpritNo
    jsr workingSprites.SetX

    iny             // SpriteNo.
    jsr workingSprites.SetX

    // Setting X Position of Jill
    ldx #30
    lda #1
    ldy #2
    jsr workingSprites.SetX

    iny
    jsr workingSprites.SetX

    // Setting Y Position of Quazzy
    lda #210
    ldy #0
    jsr workingSprites.SetY
    iny
    jsr workingSprites.SetY

    // Setting Y Position of Jill
    lda #110
    iny
    jsr workingSprites.SetY
    iny
    jsr workingSprites.SetY

    lda #0
    ldy #0
    jsr workingSprites.SetColour
    ldy #2
    jsr workingSprites.SetColour

    lda #9
    ldy #1
    jsr workingSprites.SetColour
    ldy #3
    jsr workingSprites.SetColour

    // Set MultiColour0 to 
    lda #GREEN
    sta SPMC0

    lda #LIGHT_RED
    sta SPMC1

    lda #0
    sta SpriteFrameCounter
    sta Jumping



























loop:
    sei
    lda #90                // Scanline -> A
    cmp RASTER              // Compare A to current raster line
    bne loop

    inc $D020
    jsr SortOutQuazzy

EndControls:
    // inc ScrollingFrameCounter        // increase frame counter
    // lda ScrollingFrameCounter
    // and #127                // Only count 0 -> 127 (128 cycles)
    // cmp #2                // 4 second frame counter (4 frames = .5 secs per frame)
    // bne !ByPassReSet+
    // lda #0                  // reset frame
    // sta ScrollingFrameCounter

    lda Direction
    beq !ByPassScroll+
    cmp #1
    bne DirectionLeft
    dec ScrollScrollingFrameCounter
    lda ScrollScrollingFrameCounter
    and #%00000111
    sta ScrollScrollingFrameCounter

    lda SCROLX
    and #%11111000
    ora ScrollScrollingFrameCounter
    sta SCROLX
    jsr MoveJillLeft

    lda ScrollScrollingFrameCounter
    bne !ByPassScroll+
    jsr ScrollLeft
    dec FullScreenScrollPerformed
    jmp !ByPassScroll+

DirectionLeft:
    inc ScrollScrollingFrameCounter
    lda ScrollScrollingFrameCounter
    and #%00000111
    sta ScrollScrollingFrameCounter

    lda ScrollScrollingFrameCounter
    bne !ByPassScrollHere+
    jsr ScrollRight
    dec FullScreenScrollPerformed

!ByPassScrollHere:
    lda SCROLX
    and #%11111000
    ora ScrollScrollingFrameCounter
    sta SCROLX
    jsr MoveJillRight

!ByPassScroll:
//     lda 197
//     cmp #scanCode_A
//     bne TestForDKey
//     lda #1
//     sta Direction
//     jmp EndControls

// TestForDKey:
//     cmp #scanCode_D
//     bne Nothing
//     lda #2
//     sta Direction
//     jmp EndControls

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


* = * "Quazzy Code"
SortOutQuazzy:
    inc SpriteFrameCounter
    lda SpriteFrameCounter
    cmp #32
    bne JumpingTest
    lda #0
    sta SpriteFrameCounter

JumpingTest:
    lda Jumping
    cmp #1
    bne KeyboardTest
    jsr JumpCycle

KeyboardTest:
    jsr UpdateEsmeralda
    lda 197
    cmp #scanCode_A
    bne TestForDKey
    lda #255
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForDKey:
    cmp #scanCode_D
    bne TestForLKey
    lda #1
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForLKey:
    cmp #scanCode_L
    bne TestForJoystick
    lda #1
    sta Jumping
    jmp GameLooperEnd    

TestForJoystick:
    lda CIAPRA
    eor #%11111111
    sta JoystickState
    and #joystickLeft
    cmp #joystickLeft
    bne !TestRight+
    lda #255
    sta QuazzyDirection
    jmp UpdateQuazzy

!TestRight:
    lda JoystickState
    and #joystickRight
    cmp #joystickRight
    bne !TestUp+
    lda #1
    sta QuazzyDirection
    jmp UpdateQuazzy

!TestUp:
    lda JoystickState
    and #joystickUp
    cmp #joystickUp
    bne GameLooperEnd
    lda #1
    sta Jumping
    jmp UpdateQuazzy

GameLooperEnd:
    rts

// --------------------------------------------------------------
UpdateEsmeralda:
    jsr CalculateSpriteFrame
    lda #EsmeraldaLeftBase
    clc
    adc QuazzyFrameCounter
    sta SPRITE0 + 3
    lda #EsmeraldaLeftBase + 8
    clc
    adc QuazzyFrameCounter
    sta SPRITE0 + 2
    rts

// --------------------------------------------------------------
UpdateQuazzy:
    jsr CalculateSpriteFrame
    lda QuazzyDirection
    bmi GoingLeft
    lda Jumping
    cmp #1
    beq !+

    // Quazzy Going Right
    lda #QuazzyRight
    clc
    adc QuazzyFrameCounter
    sta SPRITE0 + 1
    lda #QuazzyRight + 8
    clc
    adc QuazzyFrameCounter
    sta SPRITE0

!:
    lda SP0X
    cmp #254
    bne !NotScrollScreen+
    lda #1
    sta Direction
    jmp GameLooperEnd

!NotScrollScreen:
    inc SP0X
    inc SP0X + 2
    jmp GameLooperEnd

GoingLeft:
    // Quazzy Going Left
    lda Jumping
    cmp #1
    beq !+

    lda #QuazzyLeft
    clc
    adc QuazzyFrameCounter
    sta SPRITE0 + 1
    lda #QuazzyLeft + 8
    clc
    adc QuazzyFrameCounter
    sta SPRITE0

!:
    lda SP0X
    cmp #80
    bne !NotScrollScreen+
    lda #2
    sta Direction
    jmp GameLooperEnd

!NotScrollScreen:
    dec SP0X
    dec SP0X + 2
    jmp GameLooperEnd

// ----------------------------------------------------------------

CalculateSpriteFrame:
    lda SpriteFrameCounter
    lsr  // /2
    lsr  // /4
    lsr  // /8
//    lsr  // /16
    sta QuazzyFrameCounter
    rts

JumpCycle:
    lda SpriteFrameCounter
    beq !+
    cmp #6
    beq !+
    cmp #12
    beq !+
    cmp #18
    beq !+
    cmp #24
    beq !+
    rts
!:
    inc JumpIndex
    ldx JumpIndex
    cpx #12
    beq !EndJump+
    lda SP0Y
    clc
    adc JumpArk,x 
    sta SP0Y
    sta SP0Y + 2

    lda QuazzyDirection
    bmi LeftAni
    lda JumpAnimationRight,x 
    jmp !+

LeftAni:
    lda JumpAnimationLeft,x 
!:
    sta SPRITE0 + 1
    clc
    adc #8
    sta SPRITE0
    rts

!EndJump:
    lda #0
    sta JumpIndex
    sta Jumping
    rts

MoveJillLeft:
    sec
    lda workingSprites.XLo + 2
    sbc #1
    sta workingSprites.XLo + 2
    bcs !ByPass+
    dec workingSprites.XHi + 2
!ByPass:
    lda workingSprites.XHi + 2
    ldx workingSprites.XLo + 2
    ldy #2
    jsr workingSprites.SetX
    iny
    jsr workingSprites.SetX

    lda workingSprites.XHi + 2
    bpl !ReEnable+
    lda #0
    ldy #2
    jsr workingSprites.SetEnable
    iny
    lda #0
    jsr workingSprites.SetEnable
    jmp !ByPassEnable+
!ReEnable:
    lda workingSprites.XHi + 2
    cmp #1
    beq !DoLowTest+
    bcs !ByPassEnable+
    bcc !ByPassEnable+
!DoLowTest:
    lda workingSprites.XLo + 2
    cmp #$5E
    bcs !ByPassEnable+
    lda #1
    ldy #2
    jsr workingSprites.SetEnable
    lda #1
    iny
    jsr workingSprites.SetEnable

!ByPassEnable:
    rts

MoveJillRight:
    clc
    lda workingSprites.XLo + 2
    adc #1
    sta workingSprites.XLo + 2
    bcc !ByPass+
    inc workingSprites.XHi + 2
!ByPass:
    lda workingSprites.XHi + 2
    ldx workingSprites.XLo + 2
    ldy #2
    jsr workingSprites.SetX
    iny
    jsr workingSprites.SetX

    lda workingSprites.XHi + 2
    cmp #1
    bcc !ReEnable+
    beq !DoLoTest+
    bcs !Disable+
!DoLoTest:
    lda workingSprites.XLo + 2
    cmp #$5E
    bcc !ReEnable+
!Disable:
    lda #0
    ldy #2
    jsr workingSprites.SetEnable
    lda #0
    iny
    jsr workingSprites.SetEnable
    jmp !ByPassEnable+
!ReEnable:
    lda workingSprites.XHi
    bmi !ByPassEnable+
    lda #1
    ldy #2
    jsr workingSprites.SetEnable
    lda #1
    iny
    jsr workingSprites.SetEnable

!ByPassEnable:
    rts

* = $4400 "Map data"
    MAP_TILES:
        .import binary "Quasidemo - Tiles.bin"
    
    COLOUR_TILES:
        .import binary "Quasidemo - TileAttribs.bin"

    CHAR_ColourS:
        .import binary "Quasidemo - CharAttribs.bin"
    
    MAP_1:
        .import binary "Quasidemo - Map (20x11).bin"

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

CalculateBellFrame:
    lda ScrollingFrameCounter
    lsr  // /2
    lsr  // /4
    lsr  // /8
    lsr  // 16
    lsr  // 32
    //sta BellScrollingFrameCounter
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


* = $6000 "Chars data"
    CHARS:
        .import binary "Quasidemo - Chars.bin"

* = $6400 "Sprite Date"
    SPRITES:
        .import binary "spritesV3.bin"

#import "libSprites.asm"

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

    // inc ScrollingFrameCounter        // increase frame counter
    // lda ScrollingFrameCounter
    // and #127                // Only count 0 -> 127 (128 cycles)
    //cmp #128                // 4 second frame counter (4 frames = .5 secs per frame)
    //bne AnimateBell
    //lda #0                  // reset frame
    // sta ScrollingFrameCounter

// AnimateBell:
    //jsr CalculateBellFrame  // work out which frame the bell is currently on

    //cmp BellScrollingFrameCounter    // Bell Frame Counter same as before, no need to re-draw frame
    //bne DrawBellFrame
//     jmp EvaluateSpriteControl

// DrawBellFrame:
//     sta BellScrollingFrameCounter

//     lda #0
//     sta ZeroPageLow
//     sta ZeroPageLow + 1
    
//     ldx BellScrollingFrameCounter
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
        inc BellScrollingFrameCounter
        lda BellScrollingFrameCounter
        and #127                // Only count 0 -> 127 (128 cycles)
        cmp #30                 // 1/4 Secs
        bne !ByPassBellReDefine+
        lda #0                  // reset frame
        sta BellScrollingFrameCounter
        inc TileScrollingFrameCounter
        lda TileScrollingFrameCounter
        cmp #4
        bne !JumpOverBellReset+
        lda #0
        sta TileScrollingFrameCounter

    !JumpOverBellReset:
        ldx #<AnimationOfBellArray
        ldy #>AnimationOfBellArray
        jsr Animate.ReDefineChar

    !ByPassBellReDefine:
        inc FlameScrollingFrameCounter
        lda FlameScrollingFrameCounter
        and #127                // Only count 0 -> 127 (128 cycles)
        cmp #07                 // 1/8 Secs
        bne !ByPassFlameReDefine+
        lda #0                  // reset frame
        sta FlameScrollingFrameCounter
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


