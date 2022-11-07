BasicUpstart2(Start)

* = * "Memory Variable Storage"
VLow:       .byte 0
VFrac:      .byte 0

AccLo:      .byte 0                                 //.byte 1
AccFrac:    .byte %00010101                         //.byte %01000000

FricLo:     .byte 0                                 //.byte 1
FricFrac:   .byte %00010001                         //.byte 0

XLow:       .byte 80
XFrac:      .byte 0

Key:        .byte 0


* = * "Code Starts Here"
Start:

// Line 20
// 20 poke 2040,192 : poke 53248,80 : poke 53249,80 : poke 53287,0
    lda #192
    sta $07F8

    lda XLow
    sta $D000
    sta $D001

    lda #BLACK
    sta $D027

// Line 30
// 30 poke 53264,0 : poke 53269,1
    lda #0
    sta $D010

    lda #%00000001
    sta $D015

// Line 40 already Defaulted Variable Storage

// Line 50
// 50 k = peek(197)
Looper:
    lda #200
    cmp $D012
    bne Looper

    lda 197

// Line 60
// 60 if k = 64 and v <= 0 then v = 0 : goto 50

    cmp #64
    bne !TestSpaceBar+

    lda VLow
    bpl !ApplyFriction+

!SetVToZero:
    lda #0
    sta VLow
    sta VFrac
    jmp Looper

// Line 70
// 70 if k = 64 and v > 0 then v = v - f : goto 200
!ApplyFriction:
    // Apply Friction to Velocity
    sec
    lda VFrac
    sbc FricFrac
    sta VFrac
    lda VLow
    sbc #0
    sta VLow
    // If the Velocity is less than zero, dont update sprites X Value and reset Velocity to 0
    bmi !SetVToZero-
    // Update Sprites Position
    jmp !ApplyVelocity+

// Line 80
// 80 if k = 60 then v = v + a : goto 200
!TestSpaceBar:
    cmp #60     // Space Bar

// Line 90
// 90 goto 50
    bne Looper

    // Applying Acceleration To Velocity
    clc
    lda VFrac
    adc AccFrac
    sta VFrac
    lda VLow
    adc AccLo
    sta VLow

!ApplyVelocity:
// Line 200
// 200 x = x + v : x = x and 255

    // Applying the Velocity to The X Position
    clc 
    lda XFrac
    adc VFrac
    sta XFrac
    lda XLow
    adc VLow
    sta XLow

// Line 210
// 210 poke 53248,x
    lda XLow
    sta $D000

// Line 220
// 220 goto 50
    jmp Looper

* = * "End Of Code"

* = $3000
* = * "Sprite"
.fill 64, 255