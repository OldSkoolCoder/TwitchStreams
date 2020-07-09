#import "Constants.asm"

BasicUpstart2(start)

.label Row = $02B0
.label Col = $02B1
.label TileNumber = $02B2
.label FrameCounter = $02A8
.label BellFrameCounter = $02B3

start:
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
    ora #%00010000      // Set multicolour mode for characters
    sta SCROLX

    lda #BROWN 
    sta BGCOL1
    lda #GREY
    sta BGCOL2

    jsr DrawScreen          // Draw Map on the Screen
    jsr SpriteInitRoutine   // Initialise Sprites

loop:
    lda #240                // Scanline -> A
    cmp RASTER              // Compare A to current raster line
    bne loop

    inc $D020

    inc FrameCounter        // increase frame counter
    lda FrameCounter
    and #127                // Only count 0 -> 127 (128 cycles)
    //cmp #128                // 4 second frame counter (4 frames = .5 secs per frame)
    //bne AnimateBell
    //lda #0                  // reset frame
    sta FrameCounter

AnimateBell:
    jsr CalculateBellFrame  // work out which frame the bell is currently on

    cmp BellFrameCounter    // Bell Frame Counter same as before, no need to re-draw frame
    bne DrawBellFrame
    jmp EvaluateSpriteControl

DrawBellFrame:
    sta BellFrameCounter

    lda #0
    sta ZeroPageLow
    sta ZeroPageLow + 1
    
    ldx BellFrameCounter
    lda BellAnimationTiles,x    // get bell tile frame for the frame counter
    sta TileNumber

    sta ZeroPageLow             // work out tile character offset
    asl ZeroPageLow             // * 2
    rol ZeroPageLow + 1
    asl ZeroPageLow
    rol ZeroPageLow + 1         // * 4

    clc 
    lda #<MAP_TILES             // add offset to Map Tiles Address Location
    adc ZeroPageLow
    sta ZeroPageLow
    lda #>MAP_TILES
    adc ZeroPageLow + 1
    sta ZeroPageLow + 1

    DrawTile(ZeroPageLow, $4162, $D962)     // Draw Tile

    LIBMATH_ADD8BITTO16BIT_AV(ZeroPageLow,$04)  
    inc TileNumber
    DrawTile(ZeroPageLow, $4164, $D964)     // Draw Next Tile

EvaluateSpriteControl:
    jsr SpriteControl                       // Handle Sprites Controls

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
    lda #<SCREENRAM 
    sta Screen
    lda #>SCREENRAM 
    sta Screen + 1

    lda #<COLOURRAM
    sta Colour
    lda #>COLOURRAM
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
    cpx #$0B
    beq EndDrawRowLoop
    jmp DrawRowLoop

EndDrawRowLoop:
    rts

TileLocationOffSet:
    .byte 0, 1, 40, 41

BellAnimationTiles:
    .byte 27, 29, 27, 31

#import "SpriteExample.asm"

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