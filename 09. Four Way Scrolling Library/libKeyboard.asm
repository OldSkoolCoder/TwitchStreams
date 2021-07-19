
//=============================================================================
.macro ScanKeyboardBit(MemoryLocation)
{
// Acc = Bit To scan, Y = Result
// Parameters MemoryLocation = ResultLocation

    rol
    sta $DC00
    ldy $DC01
    sty MemoryLocation
}

.namespace libKeyboard
{
    keyboardScanByte:
        .byte 0,0,0,0,0,0,0,0,0

    ScanKeyboardMatrix:

        ldy #0
        lda #$FF

    !ClearMatrix:
        sta keyboardScanByte,y
        iny
        cpy #9
        bne !ClearMatrix-
        
        ldx #$FF
        stx $DC02       // Set Port A for Output
        ldy #$00
        sty $DC03       // Set Port B for Input

        sty $DC00       // Key For Activity
        cpx $DC01
        beq !NoKeyboardActivity+

        clc
        lda #%11111111
        ScanKeyboardBit(keyboardScanByte)
        ScanKeyboardBit(keyboardScanByte + 1)
        ScanKeyboardBit(keyboardScanByte + 2)
        ScanKeyboardBit(keyboardScanByte + 3)
        ScanKeyboardBit(keyboardScanByte + 4)
        ScanKeyboardBit(keyboardScanByte + 5)
        ScanKeyboardBit(keyboardScanByte + 6)
        ScanKeyboardBit(keyboardScanByte + 7)

        lda #$FF
        and keyboardScanByte
        and keyboardScanByte + 1
        and keyboardScanByte + 2
        and keyboardScanByte + 3
        and keyboardScanByte + 4
        and keyboardScanByte + 5
        and keyboardScanByte + 6
        and keyboardScanByte + 7
        sta keyboardScanByte + 8

    !NoKeyboardActivity:
        rts
}