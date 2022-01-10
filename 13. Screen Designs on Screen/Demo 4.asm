; 10 SYS (2064)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $34, $29, $00, $00, $00

* = $0810

SCREENRAM = $0400
COLOURRAM = $D800

SOURCEBYTE = $F0
SOURCELENGTH = $F2
DESTINATION = $F4

        ldx #>SCREENRAM
        ldy #<SCREENDATA
        lda #>SCREENDATA
        jsr DecodeScreen

        ldx #>COLOURRAM
        ldy #<COLOURDATA
        lda #>COLOURDATA
        jsr DecodeScreen

        jmp *


DecodeScreen
; Acc = Hi Location Of Screen Data
; Y = Lo Location Of Screen Data
; X = Hi Screen Location ($04 or $D8)

        ; Initialise Source Reader
        sty SOURCEBYTE
        sta SOURCEBYTE + 1

        ; Lenght is after Source
        ; increase Y by one for start of length
        iny 
        sty SOURCELENGTH
        ; Does this cross page boundary
        bne @ByPass
        ; Yes, add 1 to Acc
        clc
        adc #1
@ByPass
        sta SOURCELENGTH + 1

        ; Initialise Destination Writer
        stx DESTINATION + 1
        ldx #0
        stx DESTINATION

DecodeLooper
        ldy #0
        lda (SOURCELENGTH),y
        beq ExitDecoder
        tax

        lda (SOURCEBYTE),y

CharacterLooper
        sta (DESTINATION),y

        inc DESTINATION
        bne @ByPassInc
        inc DESTINATION + 1

@ByPassInc
        dex
        bne CharacterLooper

        clc
        lda SOURCEBYTE
        adc #2
        sta SOURCEBYTE
        bcc @ByPassIncSB
        inc SOURCEBYTE + 1

@ByPassIncSB
        clc
        lda SOURCELENGTH
        adc #2
        sta SOURCELENGTH
        bcc @ByPassIncSL
        inc SOURCELENGTH + 1

@ByPassIncSL
        jmp DecodeLooper

ExitDecoder
        rts

SCREENDATA
incbin "Intro2.sdd", 1,1, CHAR, INTERLEAVE
        BYTE 0,0

COLOURDATA
incbin "Intro2.sdd", 1,1, COLOUR, INTERLEAVE
        BYTE 0,0


gmLevelOneLandscape
incbin "NewLandScapeV2.sdd", 1, 1,CHAR, INTERLEAVE
    byte 0,0

gmLevelTwoLandscape
incbin "NewLandScapeV2.sdd", 2, 2,CHAR, INTERLEAVE
    byte 0,0

gmLevelThreeLandscape
incbin "NewLandScapeV2.sdd", 3, 3,CHAR, INTERLEAVE
    byte 0,0

gmLevelFourLandscape
incbin "NewLandScapeV2.sdd", 4, 4,CHAR, INTERLEAVE
    byte 0,0
