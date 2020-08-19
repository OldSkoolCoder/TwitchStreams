#import "Constants.asm"

//====================================================================
BasicUpstart2(start)

#import "libSprites.asm"

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

start:
    lda #147
    jsr krljmp_CHROUT

    lda #<HELLOWORLD    // Grab Lo Byte of Hello World Location
    ldy #>HELLOWORLD    // Grab Hi Byte of Hello World Location
    jsr PRINT_LINE      // Print The Line

    lda #SPRITERAM + 8
    ldy #0
    jsr libSprites.SetFrame             // Set Sprite 0 Frame

    lda #SPRITERAM
    ldy #1
    jsr libSprites.SetFrame             // Set Sprite 1 Frame

    lda #SPRITERAM + 40
    ldy #3
    jsr libSprites.SetFrame             // Set Sprite 2 Frame

    lda #SPRITERAM + 48
    ldy #2
    jsr libSprites.SetFrame             // Set Sprite 3 Frame

    ldy #0
    jsr libSprites.SpriteEnable         // Enable Sprite 0
    iny
    jsr libSprites.SpriteEnable         // Enable Sprite 1
    iny
    jsr libSprites.SpriteEnable            // Enable Sprite 2
    iny
    jsr libSprites.SpriteEnable            // Enable Sprite 3

    ldy #1 
    jsr libSprites.SpriteMultiColour    // Enable Multi Colour for Sprite 1

    ldy #3 
    jsr libSprites.SpriteMultiColour       // Enable Multi Colour for Sprite 3

    ldy #0
    jsr libSprites.SpriteBehind         // Enable Priority for Sprite 0
    iny  
    jsr libSprites.SpriteBehind         // Enable Priority for Sprite 1

    ldy #2
    jsr libSprites.SpriteLarge         // Enable Expand for Sprite 2
    iny
    jsr libSprites.SpriteLarge         // Enable Expand for Sprite 2


    ldx #60                         // X Lo
    lda #0                          // X Hi
    ldy #0
    jsr libSprites.SetX             // Set Sprite 0 X Values
    ldx #1
    jsr libSprites.CopyX            // Copy Sprite 0 to Sprite 1

    ldx #200                        // X Lo
    lda #0                          // X Hi
    ldy #2
    jsr libSprites.SetX             // Set Sprite 2 X Values
    ldx #3
    jsr libSprites.CopyX            // Copy Sprite 2 to Sprite 3

    lda #80
    ldy #0
    jsr libSprites.SetY             // Set Sprite 0 Y Values
    ldx #1
    jsr libSprites.CopyY            // Copy Sprite 0 to Sprite 1

    lda #80
    ldy #2
    jsr libSprites.SetY             // Set Sprite 2 X Values
    ldx #3
    jsr libSprites.CopyY            // Copy Sprite 2 to Sprite 3

    ldy #0 
    jsr libSprites.SpriteColourBlack // Set Colout For Sprite 0
    ldy #2
    jsr libSprites.SpriteColourBlack // Set Colout For Sprite 2

    ldy #1 
    jsr libSprites.SpriteColourBrown // Set Colout For Sprite 1
    ldy #3
    jsr libSprites.SpriteColourBrown // Set Colout For Sprite 3

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
    dec $D020
    jsr libSprites.UpdateSprites
    jmp GameLooper

// --------------------------------------------------------------
UpdateEsmeralda:
    jsr CalculateSpriteFrame
    lda #EsmeraldaLeftBase
    clc
    adc SpriteFrameCounter
    ldy #3
    jsr libSprites.SetFrame             // Set Sprite 3 Frame

    lda #EsmeraldaLeftBase + 8
    clc
    adc SpriteFrameCounter
    ldy #2
    jsr libSprites.SetFrame             // Set Sprite 2 Frame
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
    ldy #1
    jsr libSprites.SetFrame             // Set Sprite 1 Frame

    lda #QuazzyRight + 8
    clc
    adc SpriteFrameCounter
    ldy #0
    jsr libSprites.SetFrame             // Set Sprite 0 Frame

!:
    lda #0                              // X Hi
    ldx #3                              // X Lo
    ldy #0
    jsr libSprites.AddToX               // Update Sprite 0 X
    ldx #1
    jsr libSprites.CopyX                // Copy Sprite 0 X to Sprite 1 X

    jmp GameLooperEnd

GoingLeft:
    // Quazzy Going Left
    lda Jumping
    cmp #1
    beq !+

    lda #QuazzyLeft
    clc
    adc SpriteFrameCounter
    ldy #1
    jsr libSprites.SetFrame             // Set Sprite 1 Frame

    lda #QuazzyLeft + 8
    clc
    adc SpriteFrameCounter
    ldy #0
    jsr libSprites.SetFrame             // Set Sprite 0 Frame

!:
    lda #0                              // X Hi
    ldx #3                              // X Lo
    ldy #0
    jsr libSprites.SubFromX             // Update Sprite 0 X
    ldx #1
    jsr libSprites.CopyX                // Copy Sprite 0 X to Sprite 1 X

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

    lda JumpArk,x
    bmi !SubY+

    tax
    lda #0                              // Y
    ldy #0
    jsr libSprites.AddToY

    ldx #1
    jsr libSprites.CopyY
    jmp !jumpDone+

!SubY:
    // 2's Comp
    eor #$FF
    clc
    adc #1

    tax
    lda #0
    ldy #0
    jsr libSprites.SubFromY             // Update Sprite 0 Y
    ldx #1
    jsr libSprites.CopyY                // Copy Sprite 0 Y to Sprite 1 Y

!jumpDone:
    ldx JumpIndex

    lda QuazzyDirection
    bmi LeftAni
    lda JumpAnimationRight,x 
    jmp !+

LeftAni:
    lda JumpAnimationLeft,x 
!:
    pha                                 // Temp Store Away
    ldy #1
    jsr libSprites.SetFrame             // Set Sprite 1 Frame 

    pla                                 // Pull back Temp 
    clc
    adc #8
    ldy #0
    jsr libSprites.SetFrame             // Set Sprite 0 Frame
    rts

!EndJump:
    lda #0
    sta JumpIndex
    sta Jumping
    rts

HELLOWORLD:
    .byte 17, 17, 17, 17
    .text "HELLO, MY NAME IS QUAZZY OSBOURNE :)"  // the string to print
    .byte 00             // The terminator character

* = $2A80 "Sprite Date"
.import binary "spritesV3.bin"
