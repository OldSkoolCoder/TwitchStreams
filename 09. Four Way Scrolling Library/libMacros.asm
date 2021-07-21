#importonce

.macro mShiftCharactersLeft(ScreenAddr1, ScreenAddr2,StartRow,EndRow){

    // Shift Characters Left One Column

        sta RegAcc
        stx RegX

        ldx #0
    !ShiftLooper:
        .for (var row=StartRow; row<=EndRow; row++) {
            lda ScreenAddr1 + (row * 40) + 1,x
            sta ScreenAddr2 + (row * 40),x
        }
        
        inx
        cpx #39
        bne !ShiftLooper-

        ldx RegX: #$FF
        lda RegAcc: #$FF
}

.macro mShiftCharactersRight(ScreenAddr1, ScreenAddr2,StartRow,EndRow){

    // Shift Characters Left One Column

        sta RegAcc
        stx RegX

        ldx #38
    !ShiftLooper:
        .for (var row=StartRow; row<=EndRow; row++) {
            lda ScreenAddr1 + (row * 40),x
            sta ScreenAddr2 + (row * 40) + 1,x
        }
        
        dex
        bpl !ShiftLooper-

        ldx RegX: #$FF
        lda RegAcc: #$FF
}

.macro mShiftCharactersDown(ScreenAddr1, ScreenAddr2,StartRow,EndRow){

    // Shift Characters Left One Column

        sta RegAcc
        stx RegX

        ldx #38
    !ShiftLooper:
        .for (var row=EndRow; row>=StartRow; row--) {
            lda ScreenAddr1 + (row * 40),x
            sta ScreenAddr2 + ((row + 1) * 40),x
        }
        
        dex
        bpl !ShiftLooper-

        ldx RegX: #$FF
        lda RegAcc: #$FF
}

.macro mShiftCharactersUp(ScreenAddr1, ScreenAddr2,StartRow,EndRow){

    // Shift Characters Left One Column

        sta RegAcc
        stx RegX

        ldx #38
    !ShiftLooper:
        .for (var row=StartRow; row<EndRow; row++) {
            lda ScreenAddr1 + ((row + 1) * 40),x
            sta ScreenAddr2 + (row * 40),x
        }
        
        dex
        bpl !ShiftLooper-

        ldx RegX: #$FF
        lda RegAcc: #$FF
}

    .macro mLoadZPPointer(ZPLocation, Address) {
        
        lda #<Address
        sta ZPLocation

        lda #>Address
        sta ZPLocation + 1
    }
    
    .macro mLoadZPPointerWithScreenOffsetX(ZPLocation, ScreenRowAddressLo, ScreenRowAddressHi){

        lda ScreenRowAddressLo,x
        sta ZPLocation

        lda ScreenRowAddressHi,x
        sta ZPLocation + 1
    }

.macro mClearScreen(ScreenAddr1, SpaceChar){

    // Shift Characters Left One Column

        sta RegAcc
        stx RegX

        ldx #39
    !ShiftLooper:
        .for (var row=0; row<25; row++) {
            lda #SpaceChar
            sta ScreenAddr1 + (row * 40),x
        }
        
        dex
        bpl !ShiftLooper-

        ldx RegX: #$FF
        lda RegAcc: #$FF
        
}
