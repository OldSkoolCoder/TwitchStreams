#import "Constants.asm"

//====================================================================
BasicUpstart2(start)

.label PRINT_LINE   = $AB1E
.label QuazzyDirection = $02A7
.label FrameCounter = $02A8
.label SpriteFrameCounter = $02A9
.label Jumping = $02AA
.label JumpIndex = $02AB
.label JoystickState = $02AC

.label QuazzyRight = 170
.label QuazzyLeft = 174
.label QuazzyJumpRight = 186
.label QuazzyJumpLeft = 190
.label EsmeraldaRightBase = 206
.label EsmeraldaLeftBase = 202

JumpArk:
    //.byte 0, 2, 4, 8, 12, 18, 18, 12,  8,  4,  2,  0
    //.byte 0,   2,  2,  4,  4,  6,  0,249,251,251,253,253 
      .byte 0, 254,254,252,252,250,  0,  6,  6,  4,  2,  0 

JumpAnimationRight:
    //.byte 186, 187, 187, 188, 188, 188, 189, 189, 189, 190, 190, 191
    .byte 186, 186, 186, 187, 187, 187, 188, 188, 188, 189, 189, 189

JumpAnimationLeft:
    //.byte 192, 193, 193, 194, 194, 194, 195, 195, 195, 196, 196, 197
    .byte 190, 190, 190, 191, 191, 191, 192, 192, 192, 193, 193, 193

QuazzyX:
    .byte 0,0                // Quazzy : Lo Byte , Hi Byte
EsmereldaX:
    .byte 0,0                // Esmerelda

QuazzyY:
    .byte 0                // Quazzy : Lo Byte , Hi Byte
EsmereldaY:
    .byte 0                // Esmerelda


start:
    lda #147
    jsr krljmp_CHROUT

    lda #<HELLOWORLD    // Grab Lo Byte of Hello World Location
    ldy #>HELLOWORLD    // Grab Hi Byte of Hello World Location
    jsr PRINT_LINE      // Print The Line

    lda #SPRITERAM + 8
    sta SPRITE0

    lda #SPRITERAM
    sta SPRITE0 + 1

    lda #SPRITERAM + 40
    sta SPRITE0 + 3

    lda #SPRITERAM + 48
    sta SPRITE0 + 2


    lda #15      // %0000 1111
    sta SPENA
//    sta YXPAND
//    sta XXPAND

    lda #10      // %0000 1010
    sta SPMC

    lda #60
    sta QuazzyX
    lda #200
    sta EsmereldaX

    lda #80
    sta QuazzyY
    sta EsmereldaY

    lda #0
    sta SP0COL
    sta SP0COL + 2

    lda #9
    sta SP0COL + 1
    sta SP0COL + 3

    lda #5
    sta SPMC0

    lda #10
    sta SPMC1

    lda #0
    sta FrameCounter
    sta Jumping

GameLooper:
    lda #240                // Scanline -> A
    cmp RASTER              // Compare A to current raster line
    bne GameLooper

    inc $D020

    inc FrameCounter
    lda FrameCounter
    cmp #32
    bne JumpingTest
    lda #0
    sta FrameCounter

JumpingTest:
    lda Jumping
    cmp #1
    bne KeyboardTest
    jsr JumpCycle

KeyboardTest:
    jsr UpdateEsmeralda
    lda 197
    cmp #scanCode_A
    bne TestForDKey
    lda #255
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForDKey:
    cmp #scanCode_D
    bne TestForLKey
    lda #1
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForLKey:
    cmp #scanCode_L
    bne TestForJoystick
    lda #1
    sta Jumping
    jmp GameLooperEnd    

TestForJoystick:
    lda CIAPRA
    eor #%11111111
    sta JoystickState
    and #joystickLeft
    cmp #joystickLeft
    bne !TestRight+
    lda #255
    sta QuazzyDirection
    jmp UpdateQuazzy

!TestRight:
    lda JoystickState
    and #joystickRight
    cmp #joystickRight
    bne !TestUp+
    lda #1
    sta QuazzyDirection
    jmp UpdateQuazzy

!TestUp:
    lda JoystickState
    and #joystickUp
    cmp #joystickUp
    bne GameLooperEnd
    lda #1
    sta Jumping
    jmp UpdateQuazzy

GameLooperEnd:
    ldy #0
    lda QuazzyX + 1
    ldx QuazzyX
    jsr UpdateSpritesX

    ldy #1
    lda QuazzyX + 1
    ldx QuazzyX
    jsr UpdateSpritesX

    ldy #2
    lda EsmereldaX + 1
    ldx EsmereldaX
    jsr UpdateSpritesX

    ldy #3
    lda EsmereldaX + 1
    ldx EsmereldaX
    jsr UpdateSpritesX

    ldy #0
    ldx QuazzyY
    jsr UpdateSpritesY

    ldy #1
    ldx QuazzyY
    jsr UpdateSpritesY

    ldy #2
    ldx EsmereldaY
    jsr UpdateSpritesY

    ldy #3
    ldx EsmereldaY
    jsr UpdateSpritesY

    dec $D020
    jmp GameLooper

// --------------------------------------------------------------
UpdateEsmeralda:
    jsr CalculateSpriteFrame
    lda #EsmeraldaLeftBase
    clc
    adc SpriteFrameCounter
    sta SPRITE0 + 3
    lda #EsmeraldaLeftBase + 8
    clc
    adc SpriteFrameCounter
    sta SPRITE0 + 2
    rts

// --------------------------------------------------------------
UpdateQuazzy:
    jsr CalculateSpriteFrame
    lda QuazzyDirection
    bmi GoingLeft
    lda Jumping
    cmp #1
    beq !+

    // Quazzy Going Right
    lda #QuazzyRight
    clc
    adc SpriteFrameCounter
    sta SPRITE0 + 1
    lda #QuazzyRight + 8
    clc
    adc SpriteFrameCounter
    sta SPRITE0

!:
    clc
    lda QuazzyX
    adc #3
    sta QuazzyX
    lda QuazzyX + 1
    adc #0
    sta QuazzyX + 1

    jmp GameLooperEnd

GoingLeft:
    // Quazzy Going Left
    lda Jumping
    cmp #1
    beq !+

    lda #QuazzyLeft
    clc
    adc SpriteFrameCounter
    sta SPRITE0 + 1
    lda #QuazzyLeft + 8
    clc
    adc SpriteFrameCounter
    sta SPRITE0

!:
    sec
    lda QuazzyX
    sbc #3
    sta QuazzyX
    lda QuazzyX + 1
    sbc #0
    sta QuazzyX + 1

    jmp GameLooperEnd

// ----------------------------------------------------------------

CalculateSpriteFrame:
    lda FrameCounter
    lsr  // /2
    lsr  // /4
    lsr  // /8
//    lsr  // /16
    sta SpriteFrameCounter
    rts

JumpCycle:
    lda FrameCounter
    beq !+
    cmp #6
    beq !+
    cmp #12
    beq !+
    cmp #18
    beq !+
    cmp #24
    beq !+
    rts
!:
    inc JumpIndex
    ldx JumpIndex
    cpx #12
    beq !EndJump+
    lda QuazzyY
    clc
    adc JumpArk,x 
    sta QuazzyY

    lda QuazzyDirection
    bmi LeftAni
    lda JumpAnimationRight,x 
    jmp !+

LeftAni:
    lda JumpAnimationLeft,x 
!:
    sta SPRITE0 + 1
    clc
    adc #8
    sta SPRITE0
    rts

!EndJump:
    lda #0
    sta JumpIndex
    sta Jumping
    rts

SpriteMask:
    .byte %00000001         // Sprite 0
    .byte %00000010
    .byte %00000100
    .byte %00001000
    .byte %00010000
    .byte %00100000
    .byte %01000000
    .byte %10000000         // Sprite 7

UpdateSpritesX:
    // Y = Sprite Index
    // Acc = Hi Byte
    // X : Lo Byte

    pha     // Store Hi Byte on Stack For Later
    tya     // Transfer Sprite Number To Acc
    pha     // Store On Stack For Laters
    asl     // * 2
    tay     // put into Y for X Indexing
    txa     // Get Lo Byte
    sta SP0X,Y      // Store in Sprite X Lo

    pla     // Getting Back Sprite Number
    tay     // Transfer To Y

    lda #$FF
    eor SpriteMask,y    // Make Inverse Mask %00001000 => %11110111
    and MSIGX           // Clearing Out MSBit
    sta MSIGX           // Store Back.

    pla     // Bringing Back The Hi Byte
    //cmp #0  // Is it Zero
    beq !DoNothing+ // If So, Do nothing

    lda MSIGX       // Hi Byte is 1
    ora SpriteMask,y    // Set Most Sig Bit Of SpriteX
    sta MSIGX       // Store Back

!DoNothing:
    rts

UpdateSpritesY:
    // Y = Sprite Index
    // X : Y Byte

    tya     // Transfer Sprite Number To Acc
    asl     // * 2
    tay     // put into Y for X Indexing
    txa     // Get Y Byte
    sta SP0Y,Y      // Store in Sprite X Lo
    rts

HELLOWORLD:
    .text "HELLO, MY NAME IS QUAZZY OSBOURNE :)"  // the string to print
    .byte 00             // The terminator character

* = $2A80 "Sprite Date"
.import binary "spritesV3.bin"
