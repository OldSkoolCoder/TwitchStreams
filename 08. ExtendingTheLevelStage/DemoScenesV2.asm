#import "Constants.asm"
BasicUpstart2(start)

.label QuazzyRightMC = SPRITERAM + 0 //170
.label QuazzyRightHR = SPRITERAM + 8 //170
.label QuazzyLeftMC = SPRITERAM + 4 //174
.label QuazzyLeftHR = SPRITERAM + 12 //174
.label QuazzyJumpRightMC = SPRITERAM + 16 //186F
.label QuazzyJumpRightHR = SPRITERAM + 24 //186
.label QuazzyJumpLeftMC = SPRITERAM + 20 //190
.label QuazzyJumpLeftHR = SPRITERAM + 28 //190
.label JillRightBaseMC = SPRITERAM + 32 //206
.label JillRightBaseHR = SPRITERAM + 40 //206
.label JillLeftBaseMC = SPRITERAM + 36 //202
.label JillLeftBaseHR = SPRITERAM + 44 //202

.const QuazzyHiResSprNo = 0
.const QuazzyMCSprNo = 1
.const QuazzyFrameDelay = 4
.const QuazzyJumpFrameDelay = 6

.const JillHiResSprNo = 2
.const JillMCSprNo = 3
.const JillFrameDelay = 8

.const jmpSt_NotJumping = 0
.const jmpSt_StartJumping = 1
.const jmpSt_InFlight = 2

.const directionLeft = $FF
.const directionStoodStill = 0
.const directionRight = 1

#import "libSprites.asm"
#import "libJoyStick.asm"

JumpArk:
    //.byte 0, 2, 4, 8, 12, 18, 18, 12,  8,  4,  2,  0
    //.byte 0,   2,  2,  4,  4,  6,  0,249,251,251,253,253 
    .byte 0, 254,254,252,252,250,  0,  6,  6,  4,  2,  0 

JumpAnimationRightHR:
    //.byte 194, 194, 194, 195, 195, 195, 196, 196, 196, 197, 197, 197
    .byte QuazzyJumpRightHR, QuazzyJumpRightHR, QuazzyJumpRightHR
    .byte QuazzyJumpRightHR + 1, QuazzyJumpRightHR + 1, QuazzyJumpRightHR + 1
    .byte QuazzyJumpRightHR + 2, QuazzyJumpRightHR + 2, QuazzyJumpRightHR + 2
    .byte QuazzyJumpRightHR + 3, QuazzyJumpRightHR + 3, QuazzyJumpRightHR + 3
_JumpAnimationRightHR:

JumpAnimationLeftHR:
    //.byte 198, 198, 198, 199, 199, 199, 200, 200, 200, 201, 201, 201
    .byte QuazzyJumpLeftHR, QuazzyJumpLeftHR, QuazzyJumpLeftHR
    .byte QuazzyJumpLeftHR + 1, QuazzyJumpLeftHR + 1, QuazzyJumpLeftHR + 1
    .byte QuazzyJumpLeftHR + 2, QuazzyJumpLeftHR + 2, QuazzyJumpLeftHR + 2
    .byte QuazzyJumpLeftHR + 3, QuazzyJumpLeftHR + 3, QuazzyJumpLeftHR + 3
_JumpAnimationLeftHR:

.label JumpAnimationLeftHRLen = [_JumpAnimationLeftHR - JumpAnimationLeftHR]       // Number Of Bytes
.label JumpAnimationRightHRLen = [_JumpAnimationRightHR - JumpAnimationRightHR]    // Number Of Bytes

JumpAnimationRightMC:
    //.byte 186, 187, 187, 188, 188, 188, 189, 189, 189, 190, 190, 191
    //.byte 186, 186, 186, 187, 187, 187, 188, 188, 188, 189, 189, 189
    .byte QuazzyJumpLeftMC, QuazzyJumpLeftMC, QuazzyJumpLeftMC
    .byte QuazzyJumpLeftMC + 1, QuazzyJumpLeftMC + 1, QuazzyJumpLeftMC + 1
    .byte QuazzyJumpLeftMC + 2, QuazzyJumpLeftMC + 2, QuazzyJumpLeftMC + 2
    .byte QuazzyJumpLeftMC + 3, QuazzyJumpLeftMC + 3, QuazzyJumpLeftMC + 3
_JumpAnimationRightMC:

JumpAnimationLeftMC:
    //.byte 192, 193, 193, 194, 194, 194, 195, 195, 195, 196, 196, 197
    //.byte 190, 190, 190, 191, 191, 191, 192, 192, 192, 193, 193, 193
    .byte QuazzyJumpLeftHR, QuazzyJumpLeftHR, QuazzyJumpLeftHR
    .byte QuazzyJumpLeftHR + 1, QuazzyJumpLeftHR + 1, QuazzyJumpLeftHR + 1
    .byte QuazzyJumpLeftHR + 2, QuazzyJumpLeftHR + 2, QuazzyJumpLeftHR + 2
    .byte QuazzyJumpLeftHR + 3, QuazzyJumpLeftHR + 3, QuazzyJumpLeftHR + 3
_JumpAnimationLeftMC:

.label JumpAnimationLeftMCLen = [_JumpAnimationLeftMC - JumpAnimationLeftMC]       // Number Of Bytes
.label JumpAnimationRightMCLen = [_JumpAnimationRightMC - JumpAnimationRightMC]    // Number Of Bytes

AnimateQuazzyLeftMC:
    //.byte 174, 175, 176, 177
    .byte QuazzyLeftMC, QuazzyLeftMC + 1, QuazzyLeftMC + 2, QuazzyLeftMC + 3
_AnimateQuazzyLeftMC:

AnimateQuazzyRightMC:
    //.byte 170, 171, 172, 173
    .byte QuazzyRightMC, QuazzyRightMC + 1, QuazzyRightMC + 2, QuazzyRightMC + 3
_AnimateQuazzyRightMC:

.label AnimateQuazzyLeftMCLen = [_AnimateQuazzyLeftMC - AnimateQuazzyLeftMC]      // Number Of Bytes
.label AnimateQuazzyRightMCLen = [_AnimateQuazzyRightMC - AnimateQuazzyRightMC]   // Number Of Bytes

AnimateQuazzyLeftHR:
    //.byte 182, 183, 184, 185
    .byte QuazzyLeftHR, QuazzyLeftHR + 1, QuazzyLeftHR + 2, QuazzyLeftHR + 3
_AnimateQuazzyLeftHR:

AnimateQuazzyRightHR:
    //.byte 178, 179, 180, 181
    .byte QuazzyRightHR, QuazzyRightHR + 1, QuazzyRightHR + 2, QuazzyRightHR + 3
_AnimateQuazzyRightHR:

.label AnimateQuazzyLeftHRLen = [_AnimateQuazzyLeftHR - AnimateQuazzyLeftHR]     // Number Of Bytes
.label AnimateQuazzyRightHRLen = [_AnimateQuazzyRightHR - AnimateQuazzyRightHR]  // Number Of Bytes

AnimateJillMC:
    //.byte 202, 203, 204, 205
    //.byte SPRITERAM + 32, SPRITERAM + 33, SPRITERAM + 34, SPRITERAM + 35
    .byte JillLeftBaseMC, JillLeftBaseMC + 1, JillLeftBaseMC + 2, JillLeftBaseMC + 3
_AnimateJillMC:

.label AnimateJillMCLen = [_AnimateJillMC - AnimateJillMC]       // Number Of Bytes

AnimateJillHR:
    //.byte 210, 211, 212, 213
    .byte JillLeftBaseHR, JillLeftBaseHR + 1, JillLeftBaseHR + 2, JillLeftBaseHR + 3
_AnimateJillHR:

.label AnimateJillHRLen = [_AnimateJillHR - AnimateJillHR]       // Number Of Bytes

// Quazzy Movement
.label QuazzyDirection = $02A7
.label SpriteFrameCounter = $02A8
.label QuazzyFrameCounter = $02A9
.label Jumping = $02AA
.label JumpIndex = $02AB
.label JoystickState = $02AC
.label QuazzyPreviousDirection = $02AD

.label Row = $02B0
.label Col = $02B1
.label TileNumber = $02B2
.label BellScrollingFrameCounter = $02B3
.label ScrollScrollingFrameCounter = $02B4
.label Direction = $02B5
.label TileScrollingFrameCounter = $02B6
.label FlameScrollingFrameCounter = $02B7
.label FlameTileCounter = $02B8
.label FullScreenScrollPerformed = $02B9
.label ScrollingFrameCounter = $02BA

start:

    // Set Up VIC Chip to move Screen to $4000
    lda #0
    sta FullScreenScrollPerformed

    lda 1
    and #%11111110      // Bank Out BASIC
    sta 1

    lda #BLACK
    sta EXTCOL
    lda #BLACK
    sta BGCOL0

    lda $DD00
    and #%11111100
    ora #%00000010      //<- your desired VIC bank value, Bank 1
    sta $DD00

    lda $D018
    and #%00000001
    ora #%00001000      //<- your desired CharMem bank value, Screem @ $4000, Character @ $6000
    sta $D018

    lda SCROLX
    and #%11110111
//    ora #%00010000      // Set multicolour mode for characters
    sta SCROLX

    lda #BROWN 
    sta BGCOL1
    lda #GREY
    sta BGCOL2

    // Draw First Frame Of the Map
    jsr DrawScreen          // Draw Map on the Screen

    // Quazzy
    ldy #QuazzyHiResSprNo 
    ldx #QuazzyMCSprNo
    jsr libSprites.LinkSprites          // Link HiRes and MC Sprites together

    lda #QuazzyRightHR
    ldy #QuazzyHiResSprNo
    jsr libSprites.SetFrame             // Set Sprite 0 Frame

    lda #QuazzyRightMC
    ldy #QuazzyMCSprNo
    jsr libSprites.SetFrame             // Set Sprite 1 Frame

    ldy #QuazzyHiResSprNo
    jsr libSprites.SpriteEnable         // Enable Sprite 0
    ldy #JillHiResSprNo
    jsr libSprites.SpriteEnable            // Enable Sprite 2

    ldy #QuazzyMCSprNo 
    jsr libSprites.SpriteMultiColour    // Enable Multi Colour for Sprite 1


    // Jill
    ldy #JillHiResSprNo 
    ldx #JillMCSprNo
    jsr libSprites.LinkSprites

    lda #JillLeftBaseHR
    ldy #JillHiResSprNo
    jsr libSprites.SetFrame             // Set Sprite 3 Frame

    lda #JillLeftBaseMC
    ldy #JillMCSprNo
    jsr libSprites.SetFrame             // Set Sprite 2 Frame

    ldy #JillHiResSprNo
    jsr libSprites.SpriteEnable         // Enable Sprite 0
    ldy #JillMCSprNo
    jsr libSprites.SpriteEnable            // Enable Sprite 2

    ldy #JillMCSprNo 
    jsr libSprites.SpriteMultiColour       // Enable Multi Colour for Sprite 3

    ldy #JillHiResSprNo
    jsr libSprites.SpriteBehind         // Enable Priority for Sprite 0

    ldx #160                         // X Lo
    lda #0                          // X Hi
    ldy #QuazzyHiResSprNo
    jsr libSprites.SetX             // Set Sprite 0 X Values

    ldx #30                        // X Lo
    lda #1                          // X Hi
    ldy #JillHiResSprNo
    jsr libSprites.SetX             // Set Sprite 2 X Values

    lda #213
    ldy #QuazzyHiResSprNo
    jsr libSprites.SetY             // Set Sprite 0 Y Values

    lda #85
    ldy #JillHiResSprNo
    jsr libSprites.SetY             // Set Sprite 2 X Values

    ldy #QuazzyHiResSprNo 
    jsr libSprites.SpriteColourDarkGrey // Set Colout For Sprite 0
    ldy #JillHiResSprNo
    jsr libSprites.SpriteColourBlack // Set Colout For Sprite 2

    ldy #QuazzyMCSprNo 
    jsr libSprites.SpriteColourBrown // Set Colout For Sprite 1
    ldy #JillMCSprNo
    jsr libSprites.SpriteColourBrown // Set Colout For Sprite 3

    // Set MultiColour0 to 
    lda #GREEN
    sta SPMC0

    lda #LIGHT_RED
    sta SPMC1

    lda #jmpSt_NotJumping
    sta SpriteFrameCounter
    sta Jumping

    sta QuazzyDirection
    sta QuazzyPreviousDirection

    // Setting Up Quazzy's Animation
    SetAnimation(QuazzyHiResSprNo,libSprite_ACTIVE,<AnimateQuazzyRightHR,>AnimateQuazzyRightHR,AnimateQuazzyRightHRLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND)
    SetAnimation(QuazzyMCSprNo,libSprite_ACTIVE,<AnimateQuazzyRightMC,>AnimateQuazzyRightMC,AnimateQuazzyRightMCLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND)

    // Setting Up Jill's Animation
    SetAnimation(JillHiResSprNo,libSprite_ACTIVE,<AnimateJillHR,>AnimateJillHR,AnimateJillHRLen,JillFrameDelay,libSprite_LOOPING,libSprite_CONSTANT)
    SetAnimation(JillMCSprNo,libSprite_ACTIVE,<AnimateJillMC,>AnimateJillMC,AnimateJillMCLen,JillFrameDelay,libSprite_LOOPING,libSprite_CONSTANT)


GameLooper:
    sei
    lda #90                // Scanline -> A
    cmp RASTER              // Compare A to current raster line
    bne GameLooper

    inc $D020

    jsr SortOutQuazzy

EndControls:
    // inc ScrollingFrameCounter        // increase frame counter
    // lda ScrollingFrameCounter
    // and #127                // Only count 0 -> 127 (128 cycles)
    // cmp #2                // 4 second frame counter (4 frames = .5 secs per frame)
    // bne !ByPassReSet+
    // lda #0                  // reset frame
    // sta ScrollingFrameCounter

    lda Direction
    beq !ByPassScroll+
    cmp #directionRight
    bne DirectionLeft

    dec ScrollScrollingFrameCounter
    lda ScrollScrollingFrameCounter
    and #%00000111
    sta ScrollScrollingFrameCounter

//    lda ScrollScrollingFrameCounter
    cmp #$07
    bne !ByPassScrollHereTwo+
    jsr ScrollLeft

!ByPassScrollHereTwo:
    lda SCROLX
    and #%11111000
    ora ScrollScrollingFrameCounter
    sta SCROLX
    jsr MoveJillLeft
    
    jmp !ByPassScroll+

DirectionLeft:
    inc ScrollScrollingFrameCounter
    lda ScrollScrollingFrameCounter
    and #%00000111
    sta ScrollScrollingFrameCounter

    lda ScrollScrollingFrameCounter
    bne !ByPassScrollHere+
    jsr ScrollRight
    dec FullScreenScrollPerformed

!ByPassScrollHere:
    lda SCROLX
    and #%11111000
    ora ScrollScrollingFrameCounter
    sta SCROLX
    jsr MoveJillRight

!ByPassScroll:
    lda #directionStoodStill
    sta Direction

!ByPassReSet:
    lda FullScreenScrollPerformed
    bmi !ByPassAnimation+
    jsr Animate.GovernAnimationFrames

!ByPassAnimation:
    cli

    lda #0
    sta FullScreenScrollPerformed

    jsr libSprites.UpdateSprites
    
    dec $D020
    jmp GameLooper


* = * "Quazzy Code"
SortOutQuazzy:
    jsr libJoyStick.ReadJoySticks

    inc SpriteFrameCounter
    lda SpriteFrameCounter
    cmp #32
    bne JumpingTest
    lda #0
    sta SpriteFrameCounter

JumpingTest:
    lda Jumping
    //cmp #1
    beq KeyboardTest
    jsr JumpCycle

KeyboardTest:
    lda 197
    sta $4000
    cmp #scanCode_A
    bne TestForDKey
    lda #directionLeft
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForDKey:
    cmp #scanCode_D
    bne TestForLKey
    lda #directionRight
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForLKey:
    cmp #scanCode_L
    bne TestForJoystick
    lda #jmpSt_StartJumping
    sta Jumping
    jmp SortOutQuazzyEnd    

//*************************************************************************************************************
TestForJoystick:
    jsr libJoyStick.libJoy2.CheckLeft
    bcc !TestRight+
    lda #directionLeft
    sta QuazzyDirection
    jmp UpdateQuazzy
    
!TestRight:
    jsr libJoyStick.libJoy2.CheckRight
    bcc !TestUp+
    lda #directionRight
    sta QuazzyDirection
    jmp UpdateQuazzy

!TestUp:
    jsr libJoyStick.libJoy2.CheckUp
    bcc SortOutQuazzyEnd
    lda #jmpSt_StartJumping
    sta Jumping
    jmp UpdateQuazzy

//*************************************************************************************************************
SortOutQuazzyEnd:
    rts
    
// --------------------------------------------------------------
UpdateJill:
    jsr CalculateSpriteFrame
    lda #JillLeftBaseMC
    clc
    adc QuazzyFrameCounter
    sta SPRITE0 + 3
    lda #JillLeftBaseMC + 8
    clc
    adc QuazzyFrameCounter
    sta SPRITE0 + 2
    rts

// --------------------------------------------------------------
UpdateQuazzy:
    lda QuazzyDirection
    bpl !Next+
    jmp GoingLeft

!Next:
    lda Jumping
    cmp #jmpSt_StartJumping
    bcs !+

    // Setting Up Quazzy's Animation
    lda QuazzyPreviousDirection
    bpl !+
    SetAnimation(QuazzyHiResSprNo,libSprite_ACTIVE,<AnimateQuazzyRightHR,>AnimateQuazzyRightHR,AnimateQuazzyRightHRLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND)
    SetAnimation(QuazzyMCSprNo,libSprite_ACTIVE,<AnimateQuazzyRightMC,>AnimateQuazzyRightMC,AnimateQuazzyRightMCLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND)
    lda QuazzyDirection
    sta QuazzyPreviousDirection

!:
    ldy #QuazzyHiResSprNo
    jsr libSprites.GetX
    cpx #254
    bne !NotScrollScreen+
    lda #1
    sta Direction
    lda #0                              // X Frac
    ldx #0                              // X Lo
    ldy #QuazzyHiResSprNo
    jsr libSprites.AddToX               // Update Sprite 0 X
    jmp SortOutQuazzyEnd

!NotScrollScreen:
    lda #0                              // X Frac
    ldx #1                              // X Lo
    ldy #QuazzyHiResSprNo
    jsr libSprites.AddToX               // Update Sprite 0 X

    jmp SortOutQuazzyEnd

GoingLeft:
    lda Jumping
    cmp #jmpSt_StartJumping
    bcs !+

    // Setting Up Quazzy's Animation
    lda QuazzyPreviousDirection
    bmi !+
    SetAnimation(QuazzyHiResSprNo,libSprite_ACTIVE,<AnimateQuazzyLeftHR,>AnimateQuazzyLeftHR,AnimateQuazzyLeftHRLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND)
    SetAnimation(QuazzyMCSprNo,libSprite_ACTIVE,<AnimateQuazzyLeftMC,>AnimateQuazzyLeftMC,AnimateQuazzyLeftMCLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND)
    lda QuazzyDirection
    sta QuazzyPreviousDirection

!:
    ldy #QuazzyHiResSprNo
    jsr libSprites.GetX
    cpx #80

    bne !NotScrollScreen+
    lda #2
    sta Direction
    lda #0                              // X Frac
    ldx #0                              // X Lo
    ldy #QuazzyHiResSprNo
    jsr libSprites.AddToX               // Update Sprite 0 X
    jmp SortOutQuazzyEnd

!NotScrollScreen:
    lda #0                              // X Hi
    ldx #1                              // X Lo
    ldy #QuazzyHiResSprNo
    jsr libSprites.SubFromX             // Update Sprite 0 X

    jmp SortOutQuazzyEnd

// ----------------------------------------------------------------

CalculateSpriteFrame:
    lda SpriteFrameCounter
    lsr  // /2
    lsr  // /4
    lsr  // /8
//    lsr  // /16
    sta QuazzyFrameCounter
    rts

JumpCycle:
    lda SpriteFrameCounter
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
    ldy #QuazzyHiResSprNo
    jsr libSprites.AddToY

    jmp !jumpDone+

!SubY:
    // 2's Comp
    eor #$FF
    clc
    adc #1

    tax
    lda #0
    ldy #QuazzyHiResSprNo
    jsr libSprites.SubFromY             // Update Sprite 0 Y

!jumpDone:
    lda QuazzyDirection
    bmi LeftAni
    lda Jumping
    cmp #jmpSt_StartJumping 
    beq !SetAni+
    lda QuazzyPreviousDirection
    bmi !SetAni+
    jmp JumpRet

!SetAni:
    SetAnimation(QuazzyHiResSprNo,libSprite_ACTIVE,<JumpAnimationRightHR,>JumpAnimationRightHR,JumpAnimationRightHRLen,QuazzyJumpFrameDelay,libSprite_ONCE,libSprite_CONSTANT)
    SetAnimation(QuazzyMCSprNo,libSprite_ACTIVE,<JumpAnimationRightMC,>JumpAnimationRightMC,JumpAnimationRightMCLen,QuazzyJumpFrameDelay,libSprite_ONCE,libSprite_CONSTANT)
    lda QuazzyDirection
    sta QuazzyPreviousDirection
    lda #jmpSt_InFlight 
    sta Jumping
    jmp JumpRet

LeftAni:
    lda Jumping
    cmp #jmpSt_StartJumping 
    beq !SetAni+
    lda QuazzyPreviousDirection
    bmi JumpRet

!SetAni:
    SetAnimation(QuazzyHiResSprNo,libSprite_ACTIVE,<JumpAnimationLeftHR,>JumpAnimationLeftHR,JumpAnimationLeftHRLen,QuazzyJumpFrameDelay,libSprite_ONCE,libSprite_CONSTANT)
    SetAnimation(QuazzyMCSprNo,libSprite_ACTIVE,<JumpAnimationLeftMC,>JumpAnimationLeftMC,JumpAnimationLeftMCLen,QuazzyJumpFrameDelay,libSprite_ONCE,libSprite_CONSTANT)
    lda QuazzyDirection
    sta QuazzyPreviousDirection
    lda #jmpSt_InFlight 
    sta Jumping

JumpRet:
    rts

!EndJump:
    lda #jmpSt_NotJumping
    sta JumpIndex
    sta Jumping
    lda QuazzyPreviousDirection
    eor #$FF
    sta QuazzyPreviousDirection
    rts

MoveJillLeft:
    ldy #JillHiResSprNo
    ldx #1
    lda #0
    jsr libSprites.SubFromX

    ldy #JillHiResSprNo
    jsr libSprites.GetX
    // test bit 7 of Acc = xHi
    bpl !ReEnable+
    ldy #JillHiResSprNo
    jsr libSprites.SpriteDisable
    jmp !ByPassEnable+
!ReEnable:
    cmp #1
    beq !DoLowTest+
    bcs !ByPassEnable+
    bcc !ByPassEnable+
!DoLowTest:
    cpx #$5E
    bcs !ByPassEnable+
    ldy #JillHiResSprNo
    jsr libSprites.SpriteEnable

!ByPassEnable:
    rts

MoveJillRight:
    ldy #JillHiResSprNo
    ldx #1
    lda #0
    jsr libSprites.AddToX

    ldy #JillHiResSprNo
    jsr libSprites.GetX
    // Test xHi
    cmp #1
    bcc !ReEnable+
    beq !DoLoTest+
    bcs !Disable+

!DoLoTest:
    cpx #$5E
    bcc !ReEnable+

!Disable:
    ldy #JillHiResSprNo
    jsr libSprites.SpriteDisable
    jmp !ByPassEnable+

!ReEnable:
    cmp #00
    bne !ByPassEnable+
    ldy #JillHiResSprNo
    jsr libSprites.SpriteEnable

!ByPassEnable:
    rts

* = $4400 "Map data"
    MAP_TILES:
        .import binary "CastleDemoV2 - Tiles.bin"
    
    COLOUR_TILES:
        //.import binary "CastleDemoV2 - TileAttribs.bin"

    CHAR_ColourS:
        .import binary "CastleDemoV2 - CharAttribs.bin"
    
    MAP_1:
        .import binary "CastleDemoV2 - Map (40x11).bin"

TileLocationOffSet:
    .byte 0, 1, 40, 41

AnimationOfBellArray:
// Animation Array Structure
// Animating 3 Frames Per Character

    .byte $04                   // No Of Chars
    .byte $04                   // No Of Frames
    .word BellTopLeft
    .word BellTopRight
    .word BellBottomLeft
    .word BellBottomRight

    // NoOfAnimationFrames
    // BufferChar#, FrameDelay#, Frame#1Char#, Frame#2Char#, Frame#3Char#
BellTopLeft:
    .word ($6000 + 168 * 8)
    .word ($6000 + 24 * 8)
    .word ($6000 + 28 * 8)
    .word ($6000 + 24 * 8)
    .word ($6000 + 32 * 8)

BellTopRight:
    .word ($6000 + 169 * 8)
    .word ($6000 + 25 * 8)
    .word ($6000 + 29 * 8)
    .word ($6000 + 25 * 8)
    .word ($6000 + 33 * 8)

BellBottomLeft:
    .word ($6000 + 170 * 8)
    .word ($6000 + 26 * 8)
    .word ($6000 + 30 * 8)
    .word ($6000 + 26 * 8)
    .word ($6000 + 34 * 8)

BellBottomRight:
    .word ($6000 + 171 * 8)
    .word ($6000 + 27 * 8)
    .word ($6000 + 31 * 8)
    .word ($6000 + 27 * 8)
    .word ($6000 + 35 * 8)

AnimationOfFlameArray:
// Animation Array Structure
// Animating 3 Frames Per Character

    .byte $02                   // No Of Chars
    .byte $03                   // No Of Frames
    .word FlameLeft
    .word FlameRight

    // NoOfAnimationFrames
    // BufferChar#, FrameDelay#, Frame#1Char#, Frame#2Char#, Frame#3Char#
FlameLeft:
    .word ($6000 + 172 * 8)
    .word ($6000 + 64 * 8)
    .word ($6000 + 68 * 8)
    .word ($6000 + 72 * 8)

FlameRight:
    .word ($6000 + 173 * 8)
    .word ($6000 + 65 * 8)
    .word ($6000 + 69 * 8)
    .word ($6000 + 73 * 8)

AnimationOfFireOneArray:
// Animation Array Structure
// Animating 3 Frames Per Character

    .byte $02                   // No Of Chars
    .byte $03                   // No Of Frames
    .word FireOneLeft
    .word FireOneRight

    // NoOfAnimationFrames
    // BufferChar#, FrameDelay#, Frame#1Char#, Frame#2Char#, Frame#3Char#
FireOneLeft:
    .word ($6000 + 174 * 8)
    .word ($6000 + 36 * 8)
    .word ($6000 + 40 * 8)
    .word ($6000 + 44 * 8)

FireOneRight:
    .word ($6000 + 175 * 8)
    .word ($6000 + 37 * 8)
    .word ($6000 + 41 * 8)
    .word ($6000 + 45 * 8)

AnimationOfFireTwoArray:
// Animation Array Structure
// Animating 3 Frames Per Character

    .byte $02                   // No Of Chars
    .byte $03                   // No Of Frames
    .word FireTwoLeft
    .word FireTwoRight

    // NoOfAnimationFrames
    // BufferChar#, FrameDelay#, Frame#1Char#, Frame#2Char#, Frame#3Char#
FireTwoLeft:
    .word ($6000 + 176 * 8)
    .word ($6000 + 52 * 8)
    .word ($6000 + 56 * 8)
    .word ($6000 + 60 * 8)

FireTwoRight:
    .word ($6000 + 177 * 8)
    .word ($6000 + 53 * 8)
    .word ($6000 + 57 * 8)
    .word ($6000 + 61 * 8)

CalculateBellFrame:
    lda ScrollingFrameCounter
    lsr  // /2
    lsr  // /4
    lsr  // /8
    lsr  // 16
    lsr  // 32
    //sta BellScrollingFrameCounter
    rts

DrawScreen:
    lda #<SCREENRAM + (3*40) 
    sta Screen
    lda #>SCREENRAM + (3*40) 
    sta Screen + 1

    lda #<COLOURRAM + (3*40) 
    sta Colour
    lda #>COLOURRAM + (3*40) 
    sta Colour + 1

    lda #<MAP_1 //+ (3 * 50)
    sta MapTile
    lda #>MAP_1 //+ (3 * 50)
    sta MapTile + 1

    lda #0
    sta Row

DrawRowLoop:
    lda #0
    sta Col

DrawColumnLoop:
    ldy #0

    lda #0
    sta TileCharLookup
    sta TileCharLookup + 1

    lda MapTile: $DEAD      // Get Current Tile Number

    sta TileNumber
    sta TileCharLookup

    asl TileCharLookup           // * 2
    rol TileCharLookup + 1
    asl TileCharLookup
    rol TileCharLookup + 1      // * 4

    clc 
    lda #<MAP_TILES
    adc TileCharLookup
    sta TileCharLookup
    lda #>MAP_TILES
    adc TileCharLookup + 1
    sta TileCharLookup + 1

DrawTile:
    lda TileCharLookup: $B00B, y        // get Tile Character

    tax
    lda CHAR_ColourS,x
    and #$0F
    sta CharCol
    txa

    ldx TileLocationOffSet,y            // Character Offset.
    sta Screen: $BABE, x

    // ldx TileNumber
    // lda COLOUR_TILES, x                  // Colour information for tile

    lda CharCol: #$FF
    ldx TileLocationOffSet, y
    sta Colour: $BEEF,x                 // Character Colour Ram

    iny
    cpy #$04
    bne DrawTile

    LIBMATH_ADD8BITTO16BIT_AV(MapTile,$01)

    LIBMATH_ADD8BITTO16BIT_AV(Screen,$02)

    LIBMATH_ADD8BITTO16BIT_AV(Colour,$02)

    inc Col 
    ldx Col 
    cpx #$14
    beq EndDrawColumnLoop
    jmp DrawColumnLoop

EndDrawColumnLoop:  
    LIBMATH_ADD8BITTO16BIT_AV(MapTile,$14)

    LIBMATH_ADD8BITTO16BIT_AV(Screen,$28)

    LIBMATH_ADD8BITTO16BIT_AV(Colour,$28)

    inc Row 
    ldx Row 
    cpx #$0C
    beq EndDrawRowLoop
    jmp DrawRowLoop

EndDrawRowLoop:
    rts


* = $6000 "Chars data"
    CHARS:
        .import binary "CastleDemoV2 - Chars.bin"

* = $6600 "Sprite Date"
    SPRITES:
        .import binary "spritesV4.bin"

.macro LIBMATH_ADD8BITTO16BIT_AV(AddAddress,AddValue)
{
    clc
    lda AddAddress
    adc #AddValue
    sta AddAddress
    lda AddAddress + 1
    adc #$00
    sta AddAddress + 1
}

.macro DrawTile(TileLocationZeroPage, TileScreen, TileColour)
{
    ldy #0
!Tile:
    lda (TileLocationZeroPage), y        // get Tile Character

    ldx TileLocationOffSet,y            // Character Offset.
    sta TileScreen, x

    ldx TileNumber
    lda COLOUR_TILES, x                  // Colour information for tile

    ldx TileLocationOffSet, y
    sta TileColour,x                 // Character Colour Ram

    iny
    cpy #$04
    bne !Tile-
}

* = * "Scroll Right"
ScrollRight:
{
    .label Rows         = ZeroPageParam1
    .label Cols         = ZeroPageParam2
    .label ScreenLoc    = ZeroPageLow
    .label ColourLoc    = ZeroPageLow2

    .label CharTransfer = ZeroPageParam3
    .label ColTransfer = ZeroPageParam3

    .label StartOfScrollingScreen = SCREENRAM + (5 * 40)
    .label StartOfScrollingColour = COLOURRAM + (5 * 40)

RowColumnCollection:
    .for (var row=0; row<20; row++)
    {
        lda StartOfScrollingScreen + (row * 40) + 39
        pha
        lda StartOfScrollingColour + (row * 40) + 39
        pha 

        .for (var col=38; col>=0; col--)
        {
            lda StartOfScrollingScreen + (row * 40) + col
            sta StartOfScrollingScreen + (row * 40) + col + 1
            
            lda StartOfScrollingColour + (row * 40) + col
            sta StartOfScrollingColour + (row * 40) + col + 1
        }

        pla
        sta StartOfScrollingColour + (row * 40)
        pla
        sta StartOfScrollingScreen + (row * 40)
    }
    rts
}

* = * "Scroll Left"
ScrollLeft:
{
    .label Rows         = ZeroPageParam1
    .label Cols         = ZeroPageParam2
    .label ScreenLoc    = ZeroPageLow
    .label ColourLoc    = ZeroPageLow2

    .label CharTransfer = ZeroPageParam3
    .label ColTransfer = ZeroPageParam3

    .label StartOfScrollingScreen = SCREENRAM + (5 * 40)
    .label StartOfScrollingColour = COLOURRAM + (5 * 40)

    RowColumnCollection:
        .for (var row=0; row<20; row++)
        {
            lda StartOfScrollingScreen + (row * 40)
            pha
            lda StartOfScrollingColour + (row * 40)
            pha 

            .for (var col=0; col<39; col++)
            {
                lda StartOfScrollingScreen + (row * 40) + col + 1
                sta StartOfScrollingScreen + (row * 40) + col
                
                lda StartOfScrollingColour + (row * 40) + col + 1
                sta StartOfScrollingColour + (row * 40) + col
            }

            pla
            sta StartOfScrollingColour + (row * 40) + 39
            pla
            sta StartOfScrollingScreen + (row * 40) + 39
        }
        rts
}

* = * "Animate"
Animate:
{
    .label CharToRedefine= ZeroPageParam1
    .label FrameNumber   = ZeroPageParam2
    .label CurrentChar   = ZeroPageParam3

    .label ArrayZP       = ZeroPageParam4
    .label CharFrameArrayZP = ZeroPageParam6

    GovernAnimationFrames:
        inc BellScrollingFrameCounter
        lda BellScrollingFrameCounter
        and #127                // Only count 0 -> 127 (128 cycles)
        cmp #30                 // 1/4 Secs
        bne !ByPassBellReDefine+
        lda #0                  // reset frame
        sta BellScrollingFrameCounter
        inc TileScrollingFrameCounter
        lda TileScrollingFrameCounter
        cmp #4
        bne !JumpOverBellReset+
        lda #0
        sta TileScrollingFrameCounter

    !JumpOverBellReset:
        ldx #<AnimationOfBellArray
        ldy #>AnimationOfBellArray
        jsr Animate.ReDefineChar

    !ByPassBellReDefine:
        inc FlameScrollingFrameCounter
        lda FlameScrollingFrameCounter
        and #127                // Only count 0 -> 127 (128 cycles)
        cmp #07                 // 1/8 Secs
        bne !ByPassFlameReDefine+
        lda #0                  // reset frame
        sta FlameScrollingFrameCounter
        inc FlameTileCounter
        lda FlameTileCounter
        cmp #3
        bne !JumpOverFlameReset+
        lda #0
        sta FlameTileCounter

    !JumpOverFlameReset:
        ldx #<AnimationOfFlameArray
        ldy #>AnimationOfFlameArray
        jsr Animate.ReDefineChar

        lda FlameTileCounter
        ldx #<AnimationOfFireOneArray
        ldy #>AnimationOfFireOneArray
        jsr Animate.ReDefineChar

        lda FlameTileCounter
        ldx #<AnimationOfFireTwoArray
        ldy #>AnimationOfFireTwoArray
        jsr Animate.ReDefineChar

    !ByPassFlameReDefine:
        rts

    // Input Registers:
    // A = Frame Number
    // X = Array Lo
    // Y = Array Hi

    ReDefineChar:
        stx ArrayZP
        sty ArrayZP + 1

        sta FrameNumber
        ldy #0
        lda (ArrayZP),y         // No Of Chars To Redefine
        sta CharToRedefine

        ldx #0
    !CharRedefineLooper:
        inx
        txa
        asl
        tay
        dex

        lda (ArrayZP),y         // Lo Addres For Char
        sta CharFrameArrayZP
        iny
        lda (ArrayZP),y         // Lo Addres For Char
        sta CharFrameArrayZP + 1

        ldy #0
        lda (CharFrameArrayZP),y    // Lo Address Of Buffer Char
        sta BufferCharLocation
        iny
        lda (CharFrameArrayZP),y    // Lo Address Of Buffer Char
        sta BufferCharLocation + 1

        ldy FrameNumber
        iny
        tya
        asl
        tay

        lda (CharFrameArrayZP),y    // Lo Address Of Source Char
        sta SourceCharLocation
        iny
        lda (CharFrameArrayZP),y    // Lo Address Of Source Char
        sta SourceCharLocation + 1

        ldy #7
    !CharTransferLooper:
        lda SourceCharLocation: $C0DE,y
        sta BufferCharLocation: $C0DE,y 
        dey
        bpl !CharTransferLooper- 

        inx
        cpx CharToRedefine
        bne !CharRedefineLooper-
        rts
}


