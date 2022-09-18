BasicUpstart2(Start)

#import "libKeyboard.asm"

RasterReq: .byte 100

KeyPressed: .byte 0
LastKeyPressed: .byte 0

Start:
    sei

    lda #$7f
    sta $dc0d
    sta $dd0d

    lda #$35
    sta $01

    lda #<IRQ
    //sta $0314       // IRQ Low Vector
    sta $FFFE
    lda #>IRQ
    //sta $0315       // IRQ Hi Vector
    sta $FFFF

    lda #%00000001
    sta $D01A       // IRQ Mask Control Byte
                    // Bit 0 = Raster IRQ Compare

    lda $D011       // SCROLY, bit 7 = bit 8 of the Raster System, So Clearing it
    and #%01111111    
    sta $D011       // SCROLY

    lda RasterReq
    sta $D012       // RASTER = Raster Lo Value

    cli
!Looper:
    lda #240
!FrameLooper:
    cmp $D012       // Raster
    bne !FrameLooper-

    jsr libKeyboard.ScanKeyboardMatrix
    lda libKeyboard.keyboardScanByte + 1
    cmp #%00000010
    bne !TestDown+
    dec RasterReq
    jmp !UpdateVIC+

!TestDown:
    lda libKeyboard.keyboardScanByte + 1
    cmp #%00100000
    bne !Exit+
    inc RasterReq

!UpdateVIC:
    lda $D011       // SCROLY, bit 7 = bit 8 of the Raster System, So Clearing it
    and #%01111111    
    sta $D011       // SCROLY

    lda RasterReq
    sta $D012       // RASTER = Raster Lo Value

!Exit:
    jmp !Looper-


IRQ:
    pha
    txa
    pha
    tya
    pha

    lda #WHITE
    ldx $D012               // Raster Reg
!Looper:
    cpx $D012               // Raster Reg
    beq !Looper-
    sta $D020               // Border Colour
    sta $D021               // BackGround Colour

    lda #BLUE
    ldx $D012               // Raster Reg
!Looper:
    cpx $D012               // Raster Reg
    beq !Looper-
    sta $D020               // Border Colour
    sta $D021               // BackGround Colour

    // inc RasterReq

    // lda $D011       // SCROLY, bit 7 = bit 8 of the Raster System, So Clearing it
    // and #%01111111    
    // sta $D011       // SCROLY

    // lda RasterReq
    // sta $D012       // RASTER = Raster Lo Value

    asl $D019
    pla
    tay
    pla
    tax
    pla

    rti
