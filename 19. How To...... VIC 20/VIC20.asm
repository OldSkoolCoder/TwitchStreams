* = $0401 "VIC 20 BASIC Start"

BasicUpstart(GameStart)


.label VICStart = $9000
.label VICR5 = VICStart + 5
.label VICRC = VICStart + $C
.label VICRD = VICStart + $D
.label VICRE = VICStart + $E
.label VICRF = VICStart + $F
.label VIC_RASTER          = $9004

.const RASTERLINE               = 150

// UnExpaned and 3K VIC
// Screen Starts at $1E00
// Colour Ram Starts at $9600

// 9000 36864-37125 6560 Video Interface Chip
//                      A interlace mode (0 off, 1 on)
//                      B screen origin horizontal
// 9000 36864 ABBBBBBB  C screen origin vertical
// 9001 36865 CCCCCCCC  D number of video columns
// 9002 36866 HDDDDDDD  E number of video rows
// 9003 36867 GEEEEEEF  F character size (0 8x8, 1 8x16)
// 9004 36868 GGGGGGGG  G raster value
// 9005 36869 HHHHIIII  H screen memory location
// 9006 36870 JJJJJJJJ  I character memory location
// 9007 36871 KKKKKKKK  J light pen/gun horizontal
// 9008 36872 LLLLLLLL  K light pen/gun vertical
// 9009 36873 MMMMMMMM  L paddle 1
// 900A 36874 NRRRRRRR  M paddle 2
// 900B 36875 OSSSSSSS  N sound switch bass
// 900C 36876 PTTTTTTT  O sound switch alto
// 900D 36877 QUUUUUUU  P sound switch soprano
// 900E 36878 WWWWVVVV  Q sound switch noise
// 900F 36879 XXXXYZZZ  R bass frequency
//                      T soprano frequency
//                      U noise frequency
//                      V loudness
//                      W auxiliary color
//                      X screen color
//                      Y reverse screen mode
//                      Z border color
*=$0410 "Game Code Start"
GameStart:
    lda #254
    sta VICR5       // Sets the VIC Chip tto Look at memory 6144 For Chars

    lda #8
    sta VICRF       // This sets the background and border colour to Black
    sta CreateTrackRow.CurrentPos
    sta Storage.CarPosition

    lda #$93
    jsr $FFD2       // Clearing The Screen

    lda #101 + 128
    sta VICRD       // Noise 
    //sta VICRC

    lda #$0F
    sta VICRE

GameLoop:
RasterLooper:
    jsr WaitForRaster
    jsr WaitForRaster
    jsr WaitForRaster
    jsr WaitForRaster
    // jsr WaitForRaster
    // jsr WaitForRaster
    // jsr WaitForRaster
    jsr CreateTrackRow
    jsr ScrollUp
    jsr CarCrashed
    bcs !Dead+
    jsr DrawCar
    jsr JoystickCapture
    jsr MoveCar
    jmp GameLoop

!Dead:
    lda #$04
    jsr DrawCar.StoreChar

    lda #$00
    sta VICRE

    jmp *

    rts

    WaitForRaster:
    {
        RasterLooper:
            lda VIC_RASTER
            cmp #RASTERLINE
            bne RasterLooper
        !Raster:
            lda VIC_RASTER
            cmp #RASTERLINE
            beq !Raster-

            rts
    }

*=6144 "Character Set To Be Defined here"
    // Redefining the '@' character
    .byte 060, 066, 165, 129, 165, 153, 066, 060
    // Redefining the 'A' character
    .byte 028, 028, 009, 062, 072, 028, 020, 054
    // Redefining the 'B' character
    .byte 024, 090, 126, 090, 024, 219, 255, 195    
    // Redefining the 'C' character
    .byte 221, 193, 056, 187, 187, 131, 028, 221
    // Redefining the 'D' character
    .byte 073, 042, 000, 099, 000, 042, 073, 000

*=6144+(32*8)
    // Redefine The Space Character (char 32)
    .byte 0,0,0,0,0,0,0,0

Storage:
{
    JoyStick: .byte 0
    CarPosition: .byte 0
}

VIA:{
    .label VIA1PA1      = $9111
    .label VIA1DDRA     = $9113
    .label VIAIIER      = $911E
    .label VIA2PB       = $9120
    .label VIA2PA1      = $9121
    .label VIA2DDRB     = $9122
    .label VIA2DDRA     = $9123
    .label VIA2TICH     = $9125
    .label VIA2PA2      = $912F
}

.const joystickUp       = %00000001
.const joystickDown     = %00000010
.const joystickLeft     = %00000100
.const joystickRight    = %00001000
.const joystickFire     = %00010000


    ScrollUp:
    {
        lda #$1F
        sta ScreenFrom + 1
        sta ScreenTo + 1

        lda #$CE
        sta ScreenFrom
        lda #$E4
        sta ScreenTo

        ldx #0          // Row Counter
    !RowLoop:
        ldy #0          // Column Counter
    !ColLoop:
        lda ScreenFrom: $C0DE,y
        sta ScreenTo: $C0DE,y
        iny
        cpy #22
        bne !ColLoop-

        sec
        lda ScreenFrom
        sbc #22
        sta ScreenFrom
        bcs !ByPass+
        dec ScreenFrom + 1
    !ByPass:

        sec
        lda ScreenTo
        sbc #22
        sta ScreenTo
        bcs !ByPass+
        dec ScreenTo + 1
    !ByPass:

        inx
        cpx #22
        bne !RowLoop-
        ldy #0          // Column Counter
    !ColLoop:
        lda #32
        sta $1E00,y
        iny
        cpy #22
        bne !ColLoop-
        rts
    }

    JoystickCapture:
    {
        ldy #%01111111
        sty VIA.VIA2DDRB            
        lda VIA.VIA2PB              // Right Direction
        and #%10000000              // %1000 0000
        lsr                         // %0100 0000
        lsr                         // %0010 0000
        sta Storage.JoyStick
        lda VIA.VIA1PA1             // Left, Down, Up Direction
        and #%00011100              // %0001 1100
        ora Storage.JoyStick        // %0011 1100
        lsr                         // %0001 1110
        sta Storage.JoyStick
        ldy #%11111111
        sty VIA.VIA2TICH
        lda VIA.VIA1PA1             // Fire.
        and #%00100000              // %0010 0000
        ora Storage.JoyStick        // %0011 1110
        lsr                         // %0001 1111
        eor #$FF
        and #%00011111
        sta Storage.JoyStick 
        rts 
    }

    CreateTrackRow:
    {
        lda CurrentPos
        and #%01111111
        tay
        lda #$03        // Wall Character
        sta $1E00,y
        sta $1E01,y
        sta $1E0A,y
        sta $1E0B,y

        lda CurrentPos
        bmi !GoingRight+
        and #%01111111
        clc
        adc #$01

        cmp #10
        beq !ReverseToLeft+
        sta CurrentPos
        rts

    !ReverseToLeft:
        ora #%10000000
        sta CurrentPos
        rts

    !GoingRight:
        and #%01111111
        sec
        sbc #$01

        cmp #0
        beq !ReverseToRight+
        ora #%10000000
        sta CurrentPos
        rts

    !ReverseToRight:
        sta CurrentPos
        rts

        CurrentPos: .byte 0
    }
    
    DrawCar:
    {
        ldy #0          // Column Counter
    !ColLoop:
        lda #1
        sta $97E4,y
        iny
        cpy #22
        bne !ColLoop-

        lda #$02
    StoreChar:
        ldy Storage.CarPosition
        sta $1FE4,y

        sta $97E4,y
        rts
    }

    MoveCar:
    {
        lda Storage.JoyStick
        and #joystickLeft
        beq !NotGoingRight+

        ldx Storage.CarPosition
        dex
        beq !Exit+
        stx Storage.CarPosition
    !Exit:
        rts

    !NotGoingRight:
        lda Storage.JoyStick
        and #joystickRight
        beq !Exit-

        ldx Storage.CarPosition
        inx
        cpx #22
        beq !Exit-
        stx Storage.CarPosition
        rts
    }

    CarCrashed:
    {
        ldy Storage.CarPosition
        lda $1FE4,y
        cmp #32
        bne !Crashed+
        clc
        .byte $24
    !Crashed:
        sec
        rts
    }
