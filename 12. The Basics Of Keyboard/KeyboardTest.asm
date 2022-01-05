.label CIAPRA = $DC00           // Rows of the Keyboard (Port A)
.label CIAPRB = $DC01           // Columns of the Keyboard (Port B)
.label CIDDRA = $DC02           // Data Direction for Port A
.label CIDDRB = $DC03           // Data Direction for Port B
.label TEMP = $02A7

BasicUpstart2(Start)


KeyboardMatrix:
    .fill 8, 0

Start:
    ldy #$7
    lda #$FF                    // $FF = %11111111 = because by default all lines are "High" = 1
!Loop:
    sta KeyboardMatrix,y
    dey
    bpl !Loop-

    ldx #%11111111              // Data Direction Register : 0 = Input, 1 = Output
    stx CIDDRA

    ldx #%00000000              // Data Direction Register : 0 = Input, 1 = Output
    stx CIDDRB

KeyLoop:
    lda #%11111111
    clc

    ScanKeyboard(KeyboardMatrix)
    ScanKeyboard(KeyboardMatrix + 1)
    ScanKeyboard(KeyboardMatrix + 2)
    ScanKeyboard(KeyboardMatrix + 3)
    ScanKeyboard(KeyboardMatrix + 4)
    ScanKeyboard(KeyboardMatrix + 5)
    ScanKeyboard(KeyboardMatrix + 6)
    ScanKeyboard(KeyboardMatrix + 7)

    ldy #7
!Loop:
    lda KeyboardMatrix,y
    eor #$FF
    sta KeyboardMatrix,y
    dey
    bpl !Loop-
    
    PrintBinary(KeyboardMatrix, $0400)
    PrintBinary(KeyboardMatrix + 1, $0428)
    PrintBinary(KeyboardMatrix + 2, $0450)
    PrintBinary(KeyboardMatrix + 3, $0478)
    PrintBinary(KeyboardMatrix + 4, $04A0)
    PrintBinary(KeyboardMatrix + 5, $04C8)
    PrintBinary(KeyboardMatrix + 6, $04F0)
    PrintBinary(KeyboardMatrix + 7, $0518)


    // To Detect W, A, S and Z, CIAPRA = %11111101, Answer = CIAPRB
    jmp KeyLoop


    PrintBinary:
        sta TEMP
        ldy #7
    Looper1:
        lda #0
        lsr TEMP
        adc #$30
    ScrnLocal:
        sta $0400,y
        dey
        bpl Looper1
        rts


.macro ScanKeyboard(KeyboardMatrixElement)
{
    // Input Register : Accumulator = Row to Activate
    // Output Register : Y = Column Profile of the Keyboard

    // Acc : %10000000
    // Acc : %01000000

    rol
    sta CIAPRA
    ldy CIAPRB
    sty KeyboardMatrixElement

}

.macro PrintBinary(KeyboardMatrixElement, ScreenPosition) 
{
        lda KeyboardMatrixElement
        sta TEMP
        ldy #7
    Looper1:
        lda #0
        //lsr TEMP
        asl TEMP
        adc #$30
    ScrnLocal:
        sta ScreenPosition,y
        dey
        bpl Looper1
    
}


