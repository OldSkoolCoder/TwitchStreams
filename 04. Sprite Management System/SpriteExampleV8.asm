#import "Constants.asm"

//====================================================================
BasicUpstart2(start)

#import "libSprites.asm"

//*************************************************************************************************************
.label PRINT_LINE   = $AB1E
.label QuazzyDirection = $02A7
.label FrameCounter = $02A8
.label SpriteFrameCounter = $02A9
.label Jumping = $02AA              // 0 = Not Jumping, 1 or 2 = Jumping (1 = Initialise, 2 = Execute)
.label JumpIndex = $02AB
.label JoystickState = $02AC
.label QuazzyPreviousDirection = $02AD

.label QuazzyRight = 170
.label QuazzyLeft = 174
.label QuazzyJumpRight = 186
.label QuazzyJumpLeft = 190
.label EsmeraldaRightBase = 206
.label EsmeraldaLeftBase = 202

//*************************************************************************************************************
JumpArk:
      .byte 0, 254,254,252,252,250,  0,  6,  6,  4,  2,  0 

JumpAnimationRightMC:
    .byte 186, 186, 186, 187, 187, 187, 188, 188, 188, 189, 189, 189
_JumpAnimationRightMC:

JumpAnimationLeftMC:
    .byte 190, 190, 190, 191, 191, 191, 192, 192, 192, 193, 193, 193
_JumpAnimationLeftMC:

.label JumpAnimationLeftMCLen = [_JumpAnimationLeftMC - JumpAnimationLeftMC]       // Number Of Bytes
.label JumpAnimationRightMCLen = [_JumpAnimationRightMC - JumpAnimationRightMC]    // Number Of Bytes

JumpAnimationRightHR:
    .byte 194, 194, 194, 195, 195, 195, 196, 196, 196, 197, 197, 197
_JumpAnimationRightHR:

JumpAnimationLeftHR:
    .byte 198, 198, 198, 199, 199, 199, 200, 200, 200, 201, 201, 201
_JumpAnimationLeftHR:

.label JumpAnimationLeftHRLen = [_JumpAnimationLeftHR - JumpAnimationLeftHR]       // Number Of Bytes
.label JumpAnimationRightHRLen = [_JumpAnimationRightHR - JumpAnimationRightHR]    // Number Of Bytes

AnimateQuazzyLeftMC:
    .byte 174, 175, 176, 177
_AnimateQuazzyLeftMC:

AnimateQuazzyRightMC:
    .byte 170, 171, 172, 173
_AnimateQuazzyRightMC:

.label AnimateQuazzyLeftMCLen = [_AnimateQuazzyLeftMC - AnimateQuazzyLeftMC]      // Number Of Bytes
.label AnimateQuazzyRightMCLen = [_AnimateQuazzyRightMC - AnimateQuazzyRightMC]   // Number Of Bytes

AnimateQuazzyLeftHR:
    .byte 182, 183, 184, 185
_AnimateQuazzyLeftHR:

AnimateQuazzyRightHR:
    .byte 178, 179, 180, 181
_AnimateQuazzyRightHR:

.label AnimateQuazzyLeftHRLen = [_AnimateQuazzyLeftHR - AnimateQuazzyLeftHR]     // Number Of Bytes
.label AnimateQuazzyRightHRLen = [_AnimateQuazzyRightHR - AnimateQuazzyRightHR]  // Number Of Bytes

AnimateEsmeraldaMC:
    .byte 202, 203, 204, 205
_AnimateEsmeraldaMC:

.label AnimateEsmeraldaMCLen = [_AnimateEsmeraldaMC - AnimateEsmeraldaMC]       // Number Of Bytes

AnimateEsmeraldaHR:
    .byte 210, 211, 212, 213
_AnimateEsmeraldaHR:

.label AnimateEsmeraldaHRLen = [_AnimateEsmeraldaHR - AnimateEsmeraldaHR]       // Number Of Bytes

//*************************************************************************************************************
start:
    lda #147
    jsr krljmp_CHROUT

    lda #<HELLOWORLD    // Grab Lo Byte of Hello World Location
    ldy #>HELLOWORLD    // Grab Hi Byte of Hello World Location
    jsr PRINT_LINE      // Print The Line

//*************************************************************************************************************
    ldy #0 
    ldx #1
    jsr libSprites.LinkSprites

    ldy #2 
    ldx #3
    jsr libSprites.LinkSprites

    // ldy #0
    // ldx #6 
    // jsr libSprites.SwapSprites

    // ldy #1
    // ldx #7 
    // jsr libSprites.SwapSprites

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
    ldy #2
    jsr libSprites.SpriteEnable            // Enable Sprite 2

    ldy #1 
    jsr libSprites.SpriteMultiColour    // Enable Multi Colour for Sprite 1

    ldy #3 
    jsr libSprites.SpriteMultiColour       // Enable Multi Colour for Sprite 3

    ldy #0
    jsr libSprites.SpriteBehind         // Enable Priority for Sprite 0

    ldy #2
    jsr libSprites.SpriteLarge         // Enable Expand for Sprite 2


    ldx #60                         // X Lo
    lda #0                          // X Hi
    ldy #0
    jsr libSprites.SetX             // Set Sprite 0 X Values

    ldx #200                        // X Lo
    lda #0                          // X Hi
    ldy #2
    jsr libSprites.SetX             // Set Sprite 2 X Values

    lda #80
    ldy #0
    jsr libSprites.SetY             // Set Sprite 0 Y Values

    lda #80
    ldy #2
    jsr libSprites.SetY             // Set Sprite 2 X Values

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
    lda #1 
    sta QuazzyDirection
    sta QuazzyPreviousDirection

    // Setting Up Quazzy's Animation
    SetAnimation(0,libSprite_ACTIVE,<AnimateQuazzyRightHR,>AnimateQuazzyRightHR,AnimateQuazzyRightHRLen,4,libSprite_LOOPING,libSprite_ONDEMAND)
    SetAnimation(1,libSprite_ACTIVE,<AnimateQuazzyRightMC,>AnimateQuazzyRightMC,AnimateQuazzyRightMCLen,4,libSprite_LOOPING,libSprite_ONDEMAND)

    // Setting Up Esmeralda's Animation
    SetAnimation(2,libSprite_ACTIVE,<AnimateEsmeraldaHR,>AnimateEsmeraldaHR,AnimateEsmeraldaHRLen,8,libSprite_LOOPING,libSprite_CONSTANT)
    SetAnimation(3,libSprite_ACTIVE,<AnimateEsmeraldaMC,>AnimateEsmeraldaMC,AnimateEsmeraldaMCLen,8,libSprite_LOOPING,libSprite_CONSTANT)

//*************************************************************************************************************
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
    //cmp #1
    beq KeyboardTest
    jsr JumpCycle

KeyboardTest:
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

//*************************************************************************************************************
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

//*************************************************************************************************************
GameLooperEnd:
    dec $D020
    jsr libSprites.UpdateSprites
    jmp GameLooper

// --------------------------------------------------------------
UpdateQuazzy:
    lda QuazzyDirection
    bmi GoingLeft

    // Quazzy Going Right
    lda Jumping
    cmp #1
    bcs !+

    // Setting Up Quazzy's Animation
    lda QuazzyPreviousDirection
    bpl !+
    SetAnimation(0,libSprite_ACTIVE,<AnimateQuazzyRightHR,>AnimateQuazzyRightHR,AnimateQuazzyRightHRLen,4,libSprite_LOOPING,libSprite_ONDEMAND)
    SetAnimation(1,libSprite_ACTIVE,<AnimateQuazzyRightMC,>AnimateQuazzyRightMC,AnimateQuazzyRightMCLen,4,libSprite_LOOPING,libSprite_ONDEMAND)
    lda QuazzyDirection
    sta QuazzyPreviousDirection

!:
    lda #0                              // X Hi
    ldx #3                              // X Lo
    ldy #0
    jsr libSprites.AddToX               // Update Sprite 0 X

    jmp GameLooperEnd

GoingLeft:
    // Quazzy Going Left
    lda Jumping
    cmp #1
    bcs !+

    // Setting Up Quazzy's Animation
    lda QuazzyPreviousDirection
    bmi !+
    SetAnimation(0,libSprite_ACTIVE,<AnimateQuazzyLeftHR,>AnimateQuazzyLeftHR,AnimateQuazzyLeftHRLen,4,libSprite_LOOPING,libSprite_ONDEMAND)
    SetAnimation(1,libSprite_ACTIVE,<AnimateQuazzyLeftMC,>AnimateQuazzyLeftMC,AnimateQuazzyLeftMCLen,4,libSprite_LOOPING,libSprite_ONDEMAND)
    lda QuazzyDirection
    sta QuazzyPreviousDirection

!:
    lda #0                              // X Hi
    ldx #3                              // X Lo
    ldy #0
    jsr libSprites.SubFromX             // Update Sprite 0 X

    jmp GameLooperEnd

//*************************************************************************************************************
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
    bne !Jump+
    jmp !EndJump+

!Jump:
    lda JumpArk,x
    bmi !SubY+

    tax
    lda #0                              // Y
    ldy #0
    jsr libSprites.AddToY

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

!jumpDone:
    lda QuazzyDirection
    bmi LeftAni
    lda Jumping
    cmp #1 
    beq !SetAni+
    lda QuazzyPreviousDirection
    bmi !SetAni+
    jmp JumpRet
!SetAni:
    SetAnimation(0,libSprite_ACTIVE,<JumpAnimationRightHR,>JumpAnimationRightHR,JumpAnimationRightHRLen,6,libSprite_ONCE,libSprite_CONSTANT)
    SetAnimation(1,libSprite_ACTIVE,<JumpAnimationRightMC,>JumpAnimationRightMC,JumpAnimationRightMCLen,6,libSprite_ONCE,libSprite_CONSTANT)
    lda QuazzyDirection
    sta QuazzyPreviousDirection
    lda #2 
    sta Jumping
    jmp JumpRet

LeftAni:
    lda Jumping
    cmp #1 
    beq !SetAni+
    lda QuazzyPreviousDirection
    bmi JumpRet
!SetAni:
    SetAnimation(0,libSprite_ACTIVE,<JumpAnimationLeftHR,>JumpAnimationLeftHR,JumpAnimationLeftHRLen,6,libSprite_ONCE,libSprite_CONSTANT)
    SetAnimation(1,libSprite_ACTIVE,<JumpAnimationLeftMC,>JumpAnimationLeftMC,JumpAnimationLeftMCLen,6,libSprite_ONCE,libSprite_CONSTANT)
    lda QuazzyDirection
    sta QuazzyPreviousDirection
    lda #2 
    sta Jumping
JumpRet:
    rts

!EndJump:
    lda #0
    sta JumpIndex
    sta Jumping
    lda QuazzyPreviousDirection
    eor #$FF
    sta QuazzyPreviousDirection
    rts

//*************************************************************************************************************
HELLOWORLD:
    .byte 17, 17, 17, 17
    .text "HELLO, MY NAME IS QUAZZY OSBOURNE :)"  // the string to print
    .byte 00             // The terminator character

* = $2A80 "Sprite Date"
.import binary "spritesV3.bin"
