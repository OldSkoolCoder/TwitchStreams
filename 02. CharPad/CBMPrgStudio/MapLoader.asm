; 10 SYS (2064)

*=$0801

    BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $34, $29, $00, $00, $00

* = $0810

incasm "Constants.asm"


Row                 = $02B0
Col                 = $02B1
TileNumber          = $02B2
FrameCounter        = $02A8
BellFrameCounter    = $02B3

start
    lda #0  ;Black
    sta EXTCOL
    lda #6  ;BLUE
    sta BGCOL0

    lda $DD00
    and #%11111100
    ora #%00000010      ;<- your desired VIC bank value, Bank 1
    sta $DD00

    lda $D018
    and #%00000001
    ora #%00001000      ;<- your desired CharMem bank value, Screem @ $4000, Character @ $6000
    sta $D018

    lda SCROLX
    ora #%00010000      ; Set multicolour mode for characters
    sta SCROLX

    lda #9  ;BROWN 
    sta BGCOL1
    lda #12 ;GREY
    sta BGCOL2

    jsr DrawScreen          ; Draw Map on the Screen
    jsr SpriteInitRoutine   ; Initialise Sprites

loop
    lda #240                ; Scanline -> A
    cmp RASTER              ; Compare A to current raster line
    bne loop

    inc $D020

    inc FrameCounter        ; increase frame counter
    lda FrameCounter
    and #127                ; Only count 0 -> 127 (128 cycles)
    ;cmp #128                ; 4 second frame counter (4 frames = .5 secs per frame)
    ;bne AnimateBell
    ;lda #0                  ; reset frame
    sta FrameCounter

AnimateBell
    jsr CalculateBellFrame  ; work out which frame the bell is currently on

    cmp BellFrameCounter    ; Bell Frame Counter same as before, no need to re-draw frame
    bne DrawBellFrame
    jmp EvaluateSpriteControl

DrawBellFrame
    sta BellFrameCounter

    lda #0
    sta ZeroPageLow
    sta ZeroPageLow + 1
    
    ldx BellFrameCounter
    lda BellAnimationTiles,x    ; get bell tile frame for the frame counter
    sta TileNumber

    sta ZeroPageLow             ; work out tile character offset
    asl ZeroPageLow             ; * 2
    rol ZeroPageLow + 1
    asl ZeroPageLow
    rol ZeroPageLow + 1         ; * 4

    clc 
    lda #<MAP_TILES             ; add offset to Map Tiles Address Location
    adc ZeroPageLow
    sta ZeroPageLow
    lda #>MAP_TILES
    adc ZeroPageLow + 1
    sta ZeroPageLow + 1

    DrawTile ZeroPageLow, $4162, $D962     ; Draw Tile

    clc
    lda ZeroPageLow
    adc #$04
    sta ZeroPageLow
    lda ZeroPageLow + 1
    adc #$00
    sta ZeroPageLow + 1

    inc TileNumber
    DrawTile ZeroPageLow, $4164, $D964     ; Draw Next Tile

EvaluateSpriteControl
    jsr SpriteControl                       ; Handle Sprites Controls

    dec $D020
    jmp loop

CalculateBellFrame
    lda FrameCounter
    lsr  ; /2
    lsr  ; /4
    lsr  ; /8
    lsr  ; 16
    lsr  ; 32
    ;sta BellFrameCounter
    rts

DrawScreen
    lda #<SCREENRAM 
    sta Screen + 1 
    lda #>SCREENRAM 
    sta Screen + 2

    lda #<COLOURRAM
    sta Colour + 1
    lda #>COLOURRAM
    sta Colour + 2

    lda #<MAP_1
    sta MapTile + 1
    lda #>MAP_1
    sta MapTile + 2

    lda #0
    sta Row

DrawRowLoop
    lda #0
    sta Col

DrawColumnLoop
    ldy #0

    lda #0
    sta TileCharLookup + 1
    sta TileCharLookup + 2

MapTile
    lda $DEAD      ; Get Current Tile Number

    sta TileNumber
    sta TileCharLookup + 1

    asl TileCharLookup + 1           ; * 2
    rol TileCharLookup + 2
    asl TileCharLookup + 1
    rol TileCharLookup + 2          ; * 4

    clc 
    lda #<MAP_TILES
    adc TileCharLookup + 1
    sta TileCharLookup + 1
    lda #>MAP_TILES
    adc TileCharLookup + 2
    sta TileCharLookup + 2

DrawTile
TileCharLookup
    lda $B00B,y                        ; get Tile Character

    ldx TileLocationOffSet,y            ; Character Offset.
Screen
    sta $BABE,x

    ldx TileNumber
    lda COLOUR_TILES,x                  ; Colour information for tile

    ldx TileLocationOffSet,y
Colour
    sta $BEEF,x                 ; Character Colour Ram

    iny
    cpy #$04
    bne DrawTile

    LIBMATH_ADD8BITTO16BIT_AV MapTile, $01

    LIBMATH_ADD8BITTO16BIT_AV Screen, $02 

    LIBMATH_ADD8BITTO16BIT_AV Colour, $02

    inc Col 
    ldx Col 
    cpx #$14
    beq EndDrawColumnLoop
    jmp DrawColumnLoop

EndDrawColumnLoop  
    LIBMATH_ADD8BITTO16BIT_AV Screen, $28

    LIBMATH_ADD8BITTO16BIT_AV Colour, $28

    inc Row 
    ldx Row 
    cpx #$0B
    beq EndDrawRowLoop
    jmp DrawRowLoop

EndDrawRowLoop
    rts

TileLocationOffSet
    byte 0, 1, 40, 41

BellAnimationTiles
    byte 27, 29, 27, 31

incasm "SpriteExample.asm"

* = $2000 ;"Map data"
MAP_TILES
incbin"Quasidemo - Tiles.bin"

COLOUR_TILES
incbin"Quasidemo - TileAttribs.bin"

CHAR_ColourS
incbin"Quasidemo - CharAttribs.bin"

MAP_1
incbin"Quasidemo - Map (20x11).bin"

* = $6000 ;"Chars data"
CHARS
incbin"Quasidemo - Chars.bin"

defm LIBMATH_ADD8BITTO16BIT_AV ;(/1= AddAddress, /2 = AddValue)

    clc
    lda /1 + 1
    adc #/2
    sta /1 + 1
    lda /1 + 2
    adc #$00
    sta /1 + 2
endm

defm DrawTile ;(/1 = TileLocationZeroPage, /2 = TileScreen, /3 = TileColour)

    ldy #0
@Tile
    lda (/1),y        ; get Tile Character

    ldx TileLocationOffSet,y            ; Character Offset.
    sta /2,x

    ldx TileNumber
    lda COLOUR_TILES,x                  ; Colour information for tile

    ldx TileLocationOffSet,y
    sta /3,x                 ; Character Colour Ram

    iny
    cpy #$04
    bne @Tile

endm