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


        lda ScreenData + $0400,y
        sta COLOURRAM,y

        lda ScreenData + $0500,y
        sta COLOURRAM + $0100,y

        lda ScreenData + $0600,y
        sta COLOURRAM + $0200,y

        lda ScreenData + $0700,y
        sta COLOURRAM + $0300,y

        iny
        bne @Loop

        jmp *





ScreenData
        BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$46,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$4E,$58,$44,$47,$47,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$4F,$58,$58,$58,$58,$48,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$50,$58,$58,$58,$58,$58,$4A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $47,$47,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$52,$51,$58,$58,$58,$58,$58,$58,$58,$48,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $58,$58,$42,$43,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$4D,$58,$58,$58,$58,$58,$58,$58,$58,$4A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $58,$58,$58,$58,$44,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$4D,$58,$58,$58,$58,$58,$58,$58,$49,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $58,$58,$58,$58,$58,$48,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$4E,$58,$58,$58,$58,$58,$58,$58,$4B,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $58,$58,$58,$58,$58,$4A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$4C,$4C,$4C,$4F,$58,$58,$58,$58,$58,$58,$58,$48,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $58,$58,$58,$58,$58,$58,$48,$20,$20,$20,$20,$20,$20,$20,$4E,$57,$57,$57,$58,$58,$58,$58,$58,$58,$58,$58,$4A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$20
        BYTE    $58,$58,$58,$58,$58,$58,$4A,$20,$20,$20,$20,$20,$20,$20,$4F,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$48,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $58,$58,$58,$58,$58,$58,$49,$20,$20,$20,$20,$20,$20,$4E,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$4A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $58,$58,$58,$58,$58,$58,$4B,$20,$20,$20,$20,$20,$20,$4F,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$45,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $58,$58,$58,$58,$58,$45,$20,$20,$20,$20,$20,$20,$50,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$45,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $58,$58,$58,$40,$41,$20,$20,$20,$20,$20,$52,$51,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$48,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $58,$58,$45,$20,$20,$20,$20,$20,$20,$50,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$4A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $58,$45,$20,$20,$20,$20,$20,$20,$50,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$44,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
        BYTE    $58,$44,$20,$20,$20,$20,$20,$20,$53,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$42,$43,$4C,$4C,$4C,$4C,$50,$42,$43,$20,$20,$20
        BYTE    $58,$58,$44,$20,$20,$20,$20,$20,$54,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$57,$57,$57,$57,$58,$58,$58,$42,$43,$20
        BYTE    $58,$58,$58,$44,$20,$20,$20,$20,$55,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$44
        BYTE    $58,$58,$58,$58,$44,$4C,$4C,$4C,$56,$58,$58,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58
        BYTE    $58,$58,$58,$58,$58,$57,$57,$57,$58,$58,$58,$20,$13,$03,$0F,$12,$05,$20,$3A,$20,$30,$30,$30,$30,$30,$30,$20,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58,$58
        BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20

        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$01,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00
        BYTE    $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $01,$01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $01,$01,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        BYTE    $01,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$01,$00,$00,$00
        BYTE    $01,$01,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$01,$01,$01,$01,$01,$00
        BYTE    $01,$01,$01,$01,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
        BYTE    $01,$01,$01,$01,$01,$02,$02,$02,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
        BYTE    $01,$01,$01,$01,$01,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$01,$00,$01,$01,$01,$01,$01,$01,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
        BYTE    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00




