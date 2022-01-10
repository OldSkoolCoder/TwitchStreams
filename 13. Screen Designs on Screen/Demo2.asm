; 10 SYS (2064)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $34, $29, $00, $00, $00

* = $0810

SCREENRAM = $0400
COLOURRAM = $D800

        ldy #0

@loop
        lda ScreenData,y
        sta SCREENRAM,y

        lda ScreenData + $0100,y
        sta SCREENRAM + $0100,y

        lda ScreenData + $0200,y
        sta SCREENRAM + $0200,y

        lda ScreenData + $0300,y
        sta SCREENRAM + $0300,y


        lda ColourData,y
        sta COLOURRAM,y

        lda ColourData + $0100,y
        sta COLOURRAM + $0100,y

        lda ColourData + $0200,y
        sta COLOURRAM + $0200,y

        lda ColourData + $0300,y
        sta COLOURRAM + $0300,y

        iny
        bne @Loop

        jmp *

ScreenData
incbin "NewLandScapeV2.sdd", 1,1, CHAR

ColourData
incbin "NewLandScapeV2.sdd", 1,1, COLOUR
