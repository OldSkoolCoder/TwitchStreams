
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

* = * "Keyboard Library"

.namespace libKeyboard
{
    keyboardScanByte:
        .byte 0,0,0,0,0,0,0,0,0

    keyboardScanByteDeBounce:
        .byte 0,0,0,0,0,0,0,0,0

    ScanKeyboardMatrix:

        ldy #0
        ldx #$FF

    !ClearMatrix:
        lda keyboardScanByte,y
        sta keyboardScanByteDeBounce,y
        txa
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

    !NoKeyboardActivity:

        lda #0
        sta keyboardScanByte + 8

        ldy #$7
    !Loop:
        lda keyboardScanByte,y
        eor #$FF
        sta keyboardScanByte,y
        ora keyboardScanByte + 8
        sta keyboardScanByte + 8
        dey
        bpl !Loop-

        // lda #$FF
        // and keyboardScanByte
        // and keyboardScanByte + 1
        // and keyboardScanByte + 2
        // and keyboardScanByte + 3
        // and keyboardScanByte + 4
        // and keyboardScanByte + 5
        // and keyboardScanByte + 6
        // and keyboardScanByte + 7
        // sta keyboardScanByte + 8

        rts
}