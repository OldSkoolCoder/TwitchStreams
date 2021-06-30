#import "Constants.asm"
BasicUpstart2(start)

// Quazzy Movement
.label QuazzyDirection = $02A7
.label SpriteFrameCounter = $02A8
.label QuazzyFrameCounter = $02A9
.label Jumping = $02AA
.label JumpIndex = $02AB
.label JoystickState = $02AC
.label QuazzyPreviousDirection = $02AD

.label QuazzyRightMC = SPRITERAM + 0 //170
.label QuazzyRightHR = SPRITERAM + 8 //170
.label QuazzyLeftMC = SPRITERAM + 4 //174
.label QuazzyLeftHR = SPRITERAM + 12 //174
.label QuazzyJumpRightMC = SPRITERAM + 16 //186
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
    .byte SPRITERAM + 24, SPRITERAM + 24, SPRITERAM + 24, SPRITERAM + 25
    .byte SPRITERAM + 25, SPRITERAM + 25, SPRITERAM + 26, SPRITERAM + 26
    .byte SPRITERAM + 26, SPRITERAM + 27, SPRITERAM + 27, SPRITERAM + 27
_JumpAnimationRightHR:

JumpAnimationLeftHR:
    //.byte 198, 198, 198, 199, 199, 199, 200, 200, 200, 201, 201, 201
    .byte SPRITERAM + 28, SPRITERAM + 28, SPRITERAM + 28, SPRITERAM + 29
    .byte SPRITERAM + 29, SPRITERAM + 29, SPRITERAM + 30, SPRITERAM + 30
    .byte SPRITERAM + 30, SPRITERAM + 31, SPRITERAM + 31, SPRITERAM + 31
_JumpAnimationLeftHR:

.label JumpAnimationLeftHRLen = [_JumpAnimationLeftHR - JumpAnimationLeftHR]       // Number Of Bytes
.label JumpAnimationRightHRLen = [_JumpAnimationRightHR - JumpAnimationRightHR]    // Number Of Bytes

JumpAnimationRightMC:
    //.byte 186, 187, 187, 188, 188, 188, 189, 189, 189, 190, 190, 191
    //.byte 186, 186, 186, 187, 187, 187, 188, 188, 188, 189, 189, 189
    .byte SPRITERAM + 16, SPRITERAM + 16, SPRITERAM + 16, SPRITERAM + 17
    .byte SPRITERAM + 17, SPRITERAM + 17, SPRITERAM + 18, SPRITERAM + 18
    .byte SPRITERAM + 18, SPRITERAM + 19, SPRITERAM + 19, SPRITERAM + 19
_JumpAnimationRightMC:

JumpAnimationLeftMC:
    //.byte 192, 193, 193, 194, 194, 194, 195, 195, 195, 196, 196, 197
    //.byte 190, 190, 190, 191, 191, 191, 192, 192, 192, 193, 193, 193
    .byte SPRITERAM + 20, SPRITERAM + 20, SPRITERAM + 20, SPRITERAM + 21
    .byte SPRITERAM + 21, SPRITERAM + 21, SPRITERAM + 22, SPRITERAM + 22
    .byte SPRITERAM + 22, SPRITERAM + 23, SPRITERAM + 23, SPRITERAM + 23
_JumpAnimationLeftMC:

.label JumpAnimationLeftMCLen = [_JumpAnimationLeftMC - JumpAnimationLeftMC]       // Number Of Bytes
.label JumpAnimationRightMCLen = [_JumpAnimationRightMC - JumpAnimationRightMC]    // Number Of Bytes

AnimateQuazzyLeftMC:
    //.byte 174, 175, 176, 177
    .byte SPRITERAM + 4, SPRITERAM + 5, SPRITERAM + 6, SPRITERAM + 7
_AnimateQuazzyLeftMC:

AnimateQuazzyRightMC:
    //.byte 170, 171, 172, 173
    .byte SPRITERAM + 0, SPRITERAM + 1, SPRITERAM + 2, SPRITERAM + 3
_AnimateQuazzyRightMC:

.label AnimateQuazzyLeftMCLen = [_AnimateQuazzyLeftMC - AnimateQuazzyLeftMC]      // Number Of Bytes
.label AnimateQuazzyRightMCLen = [_AnimateQuazzyRightMC - AnimateQuazzyRightMC]   // Number Of Bytes

AnimateQuazzyLeftHR:
    //.byte 182, 183, 184, 185
    .byte SPRITERAM + 12, SPRITERAM + 13, SPRITERAM + 14, SPRITERAM + 15
_AnimateQuazzyLeftHR:

AnimateQuazzyRightHR:
    //.byte 178, 179, 180, 181
    .byte SPRITERAM + 8, SPRITERAM + 9, SPRITERAM + 10, SPRITERAM + 11
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
    jsr libSprites.LinkSprites

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


    // lda #SPRITERAM + 8
    // ldy #0
    // jsr workingSprites.setFrame

    // lda #SPRITERAM
    // iny
    // jsr workingSprites.setFrame

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

    // ldy #JillHiResSprNo
    // jsr libSprites.SpriteLarge         // Enable Expand for Sprite 2

    // iny
    // lda #SPRITERAM + 40
    // jsr workingSprites.setFrame

    // iny
    // lda #SPRITERAM + 32
    // jsr workingSprites.setFrame

    // Enabling the First 4 Sprites
    // lda #15      // %0000 1111
    // sta SPENA

    // Setting Sprite 1 and 3 to be MultiColour
    // lda #%00001010
    // sta SPMC

    // lda #%00001100
    // sta SPBGPR

    // Setting X Position Of Quazzy
    // lda #0          // XHi
    // ldx #80         // XLo
    // ldy #0          // SpritNo
    // jsr workingSprites.SetX

    // iny             // SpriteNo.
    // jsr workingSprites.SetX

    ldx #160                         // X Lo
    lda #0                          // X Hi
    ldy #QuazzyHiResSprNo
    jsr libSprites.SetX             // Set Sprite 0 X Values

    // Setting X Position of Jill
    // ldx #30
    // lda #1
    // ldy #2
    // jsr workingSprites.SetX

    // iny
    // jsr workingSprites.SetX

    ldx #30                        // X Lo
    lda #1                          // X Hi
    ldy #JillHiResSprNo
    jsr libSprites.SetX             // Set Sprite 2 X Values


    // Setting Y Position of Quazzy
    // lda #210
    // ldy #0
    // jsr workingSprites.SetY
    // iny
    // jsr workingSprites.SetY

    lda #210
    ldy #QuazzyHiResSprNo
    jsr libSprites.SetY             // Set Sprite 0 Y Values

    // Setting Y Position of Jill
    // lda #110
    // iny
    // jsr workingSprites.SetY
    // iny
    // jsr workingSprites.SetY

    lda #110
    ldy #JillHiResSprNo
    jsr libSprites.SetY             // Set Sprite 2 X Values

    // lda #0
    // ldy #0
    // jsr workingSprites.SetColour
    // ldy #2
    // jsr workingSprites.SetColour

    // lda #9
    // ldy #1
    // jsr workingSprites.SetColour
    // ldy #3
    // jsr workingSprites.SetColour

    ldy #QuazzyHiResSprNo 
    jsr libSprites.SpriteColourBlack // Set Colout For Sprite 0
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
    //sei
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


    
/*     dec ScrollScrollingFrameCounter
    lda ScrollScrollingFrameCounter
    and #%00000111
    sta ScrollScrollingFrameCounter

    lda SCROLX
    and #%11111000
    ora ScrollScrollingFrameCounter
    sta SCROLX
    jsr MoveJillLeft

    lda ScrollScrollingFrameCounter
    bne !ByPassScroll+
    jsr ScrollLeft
    dec FullScreenScrollPerformed
 */
 
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
//     lda 197
//     cmp #scanCode_A
//     bne TestForDKey
//     lda #1
//     sta Direction
//     jmp EndControls

// TestForDKey:
//     cmp #scanCode_D
//     bne Nothing
//     lda #2
//     sta Direction
//     jmp EndControls

Nothing:
    lda #0
    sta Direction

!ByPassReSet:
    lda FullScreenScrollPerformed
    bmi !ByPassAnimation+
    jsr Animate.GovernAnimationFrames

!ByPassAnimation:
    lda #0
    sta FullScreenScrollPerformed

    jsr libSprites.UpdateSprites

    //cli

    dec $D020
    jmp GameLooper


* = * "Quazzy Code"
SortOutQuazzy:
//     inc SpriteFrameCounter
//     lda SpriteFrameCounter
//     cmp #32
//     bne JumpingTest
//     lda #0
//     sta SpriteFrameCounter

// JumpingTest:
//     lda Jumping
//     cmp #1
//     bne KeyboardTest
//     jsr JumpCycle

// KeyboardTest:
//     jsr UpdateJill
//     lda 197
//     cmp #scanCode_A
//     bne TestForDKey
//     lda #255
//     sta QuazzyDirection
//     jmp UpdateQuazzy

// TestForDKey:
//     cmp #scanCode_D
//     bne TestForLKey
//     lda #1
//     sta QuazzyDirection
//     jmp UpdateQuazzy

// TestForLKey:
//     cmp #scanCode_L
//     bne TestForJoystick
//     lda #1
//     sta Jumping
//     jmp SortOutQuazzyEnd    

// TestForJoystick:
//     lda CIAPRA
//     eor #%11111111
//     sta JoystickState
//     and #joystickLeft
//     cmp #joystickLeft
//     bne !TestRight+
//     lda #255
//     sta QuazzyDirection
//     jmp UpdateQuazzy

// !TestRight:
//     lda JoystickState
//     and #joystickRight
//     cmp #joystickRight
//     bne !TestUp+
//     lda #1
//     sta QuazzyDirection
//     jmp UpdateQuazzy

// !TestUp:
//     lda JoystickState
//     and #joystickUp
//     cmp #joystickUp
//     bne SortOutQuazzyEnd
//     lda #1
//     sta Jumping
//     jmp UpdateQuazzy

// SortOutQuazzyEnd:
//      rts

//    jsr libJoyStick.ReadJoySticks

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
//    jmp GameLooper
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
    //jsr CalculateSpriteFrame
    // lda QuazzyDirection
    // bmi GoingLeft
    // lda Jumping
    // cmp #1
    // beq !+

    lda QuazzyDirection
    bpl !Next+
    jmp GoingLeft

    // Quazzy Going Right
    // lda #QuazzyRightMC
    // clc
    // adc QuazzyFrameCounter
    // sta SPRITE0 + 1
    // lda #QuazzyRightMC + 8
    // clc
    // adc QuazzyFrameCounter
    // sta SPRITE0

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
    // lda SP0X
    // cmp #254
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

    // inc SP0X
    // inc SP0X + 2
    jmp SortOutQuazzyEnd

GoingLeft:
    // Quazzy Going Left
    // lda Jumping
    // cmp #1
    // beq !+

    lda Jumping
    cmp #jmpSt_StartJumping
    bcs !+

    // lda #QuazzyLeftMC
    // clc
    // adc QuazzyFrameCounter
    // sta SPRITE0 + 1
    // lda #QuazzyLeftMC + 8
    // clc
    // adc QuazzyFrameCounter
    // sta SPRITE0

    // Setting Up Quazzy's Animation
    lda QuazzyPreviousDirection
    bmi !+
    SetAnimation(QuazzyHiResSprNo,libSprite_ACTIVE,<AnimateQuazzyLeftHR,>AnimateQuazzyLeftHR,AnimateQuazzyLeftHRLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND)
    SetAnimation(QuazzyMCSprNo,libSprite_ACTIVE,<AnimateQuazzyLeftMC,>AnimateQuazzyLeftMC,AnimateQuazzyLeftMCLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND)
    lda QuazzyDirection
    sta QuazzyPreviousDirection

!:
    // lda SP0X
    // cmp #80
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
    // dec SP0X
    // dec SP0X + 2

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
//     beq !EndJump+
//     lda SP0Y
//     clc
//     adc JumpArk,x 
//     sta SP0Y
//     sta SP0Y + 2

//     lda QuazzyDirection
//     bmi LeftAni
//     lda JumpAnimationRight,x 
//     jmp !+

// LeftAni:
//     lda JumpAnimationLeft,x 
// !:
//     sta SPRITE0 + 1
//     clc
//     adc #8
//     sta SPRITE0
//     rts

// !EndJump:
//     lda #0
//     sta JumpIndex
//     sta Jumping

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

//     sec
//     lda workingSprites.XLo + 2
//     sbc #1
//     sta workingSprites.XLo + 2
//     bcs !ByPass+
//     dec workingSprites.XHi + 2
// !ByPass:
//     lda workingSprites.XHi + 2
//     ldx workingSprites.XLo + 2
//     ldy #2
//     jsr workingSprites.SetX
//     iny
//     jsr workingSprites.SetX

    //lda workingSprites.XHi + 2
    ldy #JillHiResSprNo
    jsr libSprites.GetX
    // test bit 7 of Acc = xHi
    bpl !ReEnable+
    // lda #0
    // ldy #2
    // jsr workingSprites.SetEnable
    // iny
    // lda #0
    // jsr workingSprites.SetEnable
    ldy #JillHiResSprNo
    jsr libSprites.SpriteDisable
    jmp !ByPassEnable+
!ReEnable:
    //lda workingSprites.XHi + 2
    cmp #1
    beq !DoLowTest+
    bcs !ByPassEnable+
    bcc !ByPassEnable+
!DoLowTest:
    //lda workingSprites.XLo + 2
    cpx #$5E
    bcs !ByPassEnable+
    // lda #1
    // ldy #2
    // jsr workingSprites.SetEnable
    // lda #1
    // iny
    // jsr workingSprites.SetEnable
    ldy #JillHiResSprNo
    jsr libSprites.SpriteEnable

!ByPassEnable:
    rts

MoveJillRight:
    ldy #JillHiResSprNo
    ldx #1
    lda #0
    jsr libSprites.AddToX

//     clc
//     lda workingSprites.XLo + 2
//     adc #1
//     sta workingSprites.XLo + 2
//     bcc !ByPass+
//     inc workingSprites.XHi + 2
// !ByPass:
//     lda workingSprites.XHi + 2
//     ldx workingSprites.XLo + 2
//     ldy #2
//     jsr workingSprites.SetX
//     iny
//     jsr workingSprites.SetX

//    lda workingSprites.XHi + 2
    ldy #JillHiResSprNo
    jsr libSprites.GetX
    // Test xHi
    cmp #1
    bcc !ReEnable+
    beq !DoLoTest+
    bcs !Disable+
!DoLoTest:
//    lda workingSprites.XLo + 2
    cpx #$5E
    bcc !ReEnable+
!Disable:
    // lda #0
    // ldy #2
    // jsr workingSprites.SetEnable
    // lda #0
    // iny
    // jsr workingSprites.SetEnable
    ldy #JillHiResSprNo
    jsr libSprites.SpriteDisable
    jmp !ByPassEnable+
!ReEnable:
    //lda workingSprites.XHi
    cmp #00
    bne !ByPassEnable+
    // lda #1
    // ldy #2
    // jsr workingSprites.SetEnable
    // lda #1
    // iny
    // jsr workingSprites.SetEnable
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

    // inc ScrollingFrameCounter        // increase frame counter
    // lda ScrollingFrameCounter
    // and #127                // Only count 0 -> 127 (128 cycles)
    //cmp #128                // 4 second frame counter (4 frames = .5 secs per frame)
    //bne AnimateBell
    //lda #0                  // reset frame
    // sta ScrollingFrameCounter

// AnimateBell:
    //jsr CalculateBellFrame  // work out which frame the bell is currently on

    //cmp BellScrollingFrameCounter    // Bell Frame Counter same as before, no need to re-draw frame
    //bne DrawBellFrame
//     jmp EvaluateSpriteControl

// DrawBellFrame:
//     sta BellScrollingFrameCounter

//     lda #0
//     sta ZeroPageLow
//     sta ZeroPageLow + 1
    
//     ldx BellScrollingFrameCounter
//     lda BellAnimationTiles,x    // get bell tile frame for the frame counter
//     sta TileNumber

//     sta ZeroPageLow             // work out tile character offset
//     asl ZeroPageLow             // * 2
//     rol ZeroPageLow + 1
//     asl ZeroPageLow
//     rol ZeroPageLow + 1         // * 4

//     clc 
//     lda #<MAP_TILES             // add offset to Map Tiles Address Location
//     adc ZeroPageLow
//     sta ZeroPageLow
//     lda #>MAP_TILES
//     adc ZeroPageLow + 1
//     sta ZeroPageLow + 1

//     DrawTile(ZeroPageLow, $4162, $D962)     // Draw Tile

//     LIBMATH_ADD8BITTO16BIT_AV(ZeroPageLow,$04)  
//     inc TileNumber
//     DrawTile(ZeroPageLow, $4164, $D964)     // Draw Next Tile

// EvaluateSpriteControl:

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

    //     ldy #38
    // !ColumnLooper:
    //     lda StartOfScrollingScreen + (row * 40),y
    //     iny
    //     sta StartOfScrollingScreen + (row * 40),y
    //     dey

    //     lda StartOfScrollingColour + (row * 40),y
    //     iny
    //     sta StartOfScrollingColour + (row * 40),y
    //     dey

    //     dey
    //     bpl !ColumnLooper-

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


