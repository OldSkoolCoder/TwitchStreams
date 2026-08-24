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

loop:

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