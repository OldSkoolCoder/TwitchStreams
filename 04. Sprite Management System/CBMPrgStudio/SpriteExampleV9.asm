; 10 SYS (2064)

*=$0801

    BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $34, $29, $00, $00, $00

* = $0810
    jmp start

incasm "Constants.asm"

incasm "libSpritesMultiPlex.asm"

;*************************************************************************************************************
QuazzyHiResSprNo = 0
QuazzyMCSprNo = 1
QuazzyFrameDelay = 4
QuazzyJumpFrameDelay = 6

EsmerelldaHiResSprNo = 2
EsmerelldaMCSprNo = 3
EsmerelldaFrameDelay = 8

jmpSt_NotJumping = 0
jmpSt_StartJumping = 1
jmpSt_InFlight = 2

directionLeft = $FF
directionStoodStill = 0
directionRight = 1

;*************************************************************************************************************
PRINT_LINE   = $AB1E
QuazzyDirection = $02A7
FrameCounter = $02A8
SpriteFrameCounter = $02A9
Jumping = $02AA              ; 0 = Not Jumping, 1 or 2 = Jumping (1 = Initialise, 2 = Execute)
JumpIndex = $02AB
JoystickState = $02AC
QuazzyPreviousDirection = $02AD

QuazzyRight = 170
QuazzyLeft = 174
QuazzyJumpRight = 186
QuazzyJumpLeft = 190
EsmeraldaRightBase = 206
EsmeraldaLeftBase = 202

;"Quazzy Data Storage"
;*************************************************************************************************************
JumpArk
    byte 0, 254,254,252,252,250,  0,  6,  6,  4,  2,  0 

JumpAnimationRightMC
    byte 186, 186, 186, 187, 187, 187, 188, 188, 188, 189, 189, 189
_JumpAnimationRightMC

JumpAnimationLeftMC
    byte 190, 190, 190, 191, 191, 191, 192, 192, 192, 193, 193, 193
_JumpAnimationLeftMC

JumpAnimationLeftMCLen = _JumpAnimationLeftMC - JumpAnimationLeftMC       ; Number Of Bytes
JumpAnimationRightMCLen = _JumpAnimationRightMC - JumpAnimationRightMC    ; Number Of Bytes

JumpAnimationRightHR
    byte 194, 194, 194, 195, 195, 195, 196, 196, 196, 197, 197, 197
_JumpAnimationRightHR

JumpAnimationLeftHR
    byte 198, 198, 198, 199, 199, 199, 200, 200, 200, 201, 201, 201
_JumpAnimationLeftHR

JumpAnimationLeftHRLen = _JumpAnimationLeftHR - JumpAnimationLeftHR       ; Number Of Bytes
JumpAnimationRightHRLen = _JumpAnimationRightHR - JumpAnimationRightHR    ; Number Of Bytes

AnimateQuazzyLeftMC
    byte 174, 175, 176, 177
_AnimateQuazzyLeftMC

AnimateQuazzyRightMC
    byte 170, 171, 172, 173
_AnimateQuazzyRightMC

AnimateQuazzyLeftMCLen = _AnimateQuazzyLeftMC - AnimateQuazzyLeftMC      ; Number Of Bytes
AnimateQuazzyRightMCLen = _AnimateQuazzyRightMC - AnimateQuazzyRightMC   ; Number Of Bytes

AnimateQuazzyLeftHR
    byte 182, 183, 184, 185
_AnimateQuazzyLeftHR

AnimateQuazzyRightHR
    byte 178, 179, 180, 181
_AnimateQuazzyRightHR

AnimateQuazzyLeftHRLen = _AnimateQuazzyLeftHR - AnimateQuazzyLeftHR     ; Number Of Bytes
AnimateQuazzyRightHRLen = _AnimateQuazzyRightHR - AnimateQuazzyRightHR  ; Number Of Bytes

AnimateEsmeraldaMC
    byte 202, 203, 204, 205
_AnimateEsmeraldaMC

AnimateEsmeraldaMCLen = _AnimateEsmeraldaMC - AnimateEsmeraldaMC       ; Number Of Bytes

AnimateEsmeraldaHR
    byte 210, 211, 212, 213
_AnimateEsmeraldaHR

AnimateEsmeraldaHRLen = _AnimateEsmeraldaHR - AnimateEsmeraldaHR       ; Number Of Bytes

; "Start Example Code"
;*************************************************************************************************************
start

    lda #147
    jsr krljmp_CHROUT

    lda #<HELLOWORLD    ; Grab Lo Byte of Hello World Location
    ldy #>HELLOWORLD    ; Grab Hi Byte of Hello World Location
    jsr PRINT_LINE      ; Print The Line

;*************************************************************************************************************
    ldy #QuazzyHiResSprNo 
    ldx #QuazzyMCSprNo
    jsr LinkSprites

    ldy #EsmerelldaHiResSprNo 
    ldx #EsmerelldaMCSprNo
    jsr LinkSprites

    ; Adds 7 more Esmerelda's
;repeat 7, i
;        ldy #4 + (i*2) 
;        ldx #5 + (i*2)
;        jsr LinkSprites

;        ldy #5 + (i*2)
;        jsr SpriteMultiColour       ; Enable Multi Colour for Sprite 3

;        ldx #190 - (i*10)                        ; X Lo
;        lda #0                          ; X Hi
;        ldy #4 + (i*2) 
;        jsr SetX             ; Set Sprite 2 X Values

;        lda #90 + (i*15)
;        ldy #4 + (i*2) 
;        jsr SetY             ; Set Sprite 2 X Values

;        ldy #5 + (i*2) 
;        jsr SpriteColourBrown ; Set Colout For Sprite 3

;        SetAnimation(4 + (i*2),libSprite_ACTIVE,<AnimateEsmeraldaHR,>AnimateEsmeraldaHR,AnimateEsmeraldaHRLen,EsmerelldaFrameDelay,libSprite_LOOPING,libSprite_CONSTANT)
;        SetAnimation(5 + (i*2),libSprite_ACTIVE,<AnimateEsmeraldaMC,>AnimateEsmeraldaMC,AnimateEsmeraldaMCLen,EsmerelldaFrameDelay,libSprite_LOOPING,libSprite_CONSTANT)

;        ldy #4 + (i*2) 
;        jsr SpriteEnable            ; Enable Sprite 2
;end repeat
    
    lda #SPRITERAM + 8
    ldy #QuazzyHiResSprNo
    jsr SetFrame             ; Set Sprite 0 Frame

    lda #SPRITERAM
    ldy #QuazzyMCSprNo
    jsr SetFrame             ; Set Sprite 1 Frame

    lda #SPRITERAM + 48
    ldy #EsmerelldaHiResSprNo
    jsr SetFrame             ; Set Sprite 3 Frame

    lda #SPRITERAM + 40
    ldy #EsmerelldaMCSprNo
    jsr SetFrame             ; Set Sprite 2 Frame

    ldy #QuazzyHiResSprNo
    jsr SpriteEnable         ; Enable Sprite 0
    ldy #EsmerelldaHiResSprNo
    jsr SpriteEnable            ; Enable Sprite 2

    ldy #QuazzyMCSprNo 
    jsr SpriteMultiColour    ; Enable Multi Colour for Sprite 1

    ldy #EsmerelldaMCSprNo 
    jsr SpriteMultiColour       ; Enable Multi Colour for Sprite 3

    ldy #QuazzyHiResSprNo
    jsr SpriteBehind         ; Enable Priority for Sprite 0

    ldy #EsmerelldaHiResSprNo
    jsr SpriteLarge         ; Enable Expand for Sprite 2


    ldx #60                         ; X Lo
    lda #0                          ; X Hi
    ldy #QuazzyHiResSprNo
    jsr SetX             ; Set Sprite 0 X Values

    ldx #200                        ; X Lo
    lda #0                          ; X Hi
    ldy #EsmerelldaHiResSprNo
    jsr SetX             ; Set Sprite 2 X Values

    lda #80
    ldy #QuazzyHiResSprNo
    jsr SetY             ; Set Sprite 0 Y Values

    lda #80
    ldy #EsmerelldaHiResSprNo
    jsr SetY             ; Set Sprite 2 X Values

    ldy #QuazzyHiResSprNo 
    jsr SpriteColourBlack ; Set Colout For Sprite 0
    ldy #EsmerelldaHiResSprNo
    jsr SpriteColourBlack ; Set Colout For Sprite 2

    ldy #QuazzyMCSprNo 
    jsr SpriteColourBrown ; Set Colout For Sprite 1
    ldy #EsmerelldaMCSprNo
    jsr SpriteColourBrown ; Set Colout For Sprite 3

    lda #5
    sta SPMC0

    lda #10
    sta SPMC1

    lda #jmpSt_NotJumping
    sta FrameCounter
    sta Jumping
    lda #directionRight 
    sta QuazzyDirection
    sta QuazzyPreviousDirection

    ; Setting Up Quazzy's Animation
    SetAnimation QuazzyHiResSprNo,libSprite_ACTIVE,<AnimateQuazzyRightHR,>AnimateQuazzyRightHR,AnimateQuazzyRightHRLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND 
    SetAnimation QuazzyMCSprNo,libSprite_ACTIVE,<AnimateQuazzyRightMC,>AnimateQuazzyRightMC,AnimateQuazzyRightMCLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND 

    ; Setting Up Esmeralda's Animation
    SetAnimation EsmerelldaHiResSprNo,libSprite_ACTIVE,<AnimateEsmeraldaHR,>AnimateEsmeraldaHR,AnimateEsmeraldaHRLen,EsmerelldaFrameDelay,libSprite_LOOPING,libSprite_CONSTANT 
    SetAnimation EsmerelldaMCSprNo,libSprite_ACTIVE,<AnimateEsmeraldaMC,>AnimateEsmeraldaMC,AnimateEsmeraldaMCLen,EsmerelldaFrameDelay,libSprite_LOOPING,libSprite_CONSTANT 

    ; Initialise Multiplexor
    ;jsr MultiplexorInit

    ; Enable Multiplexor
    ;jsr EnableMUX

;*************************************************************************************************************
GameLooper
    lda #240                ; Scanline -> A
    cmp RASTER              ; Compare A to current raster line
    bne GameLooper

    ;inc $D020

    inc FrameCounter
    lda FrameCounter
    cmp #32
    bne JumpingTest
    lda #0
    sta FrameCounter

JumpingTest
    lda Jumping
    ;cmp #1
    beq KeyboardTest
    jsr JumpCycle

KeyboardTest
    lda 197
    cmp #scanCode_A
    bne TestForDKey
    lda #directionLeft
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForDKey
    cmp #scanCode_D
    bne TestForLKey
    lda #directionRight
    sta QuazzyDirection
    jmp UpdateQuazzy

TestForLKey
    cmp #scanCode_L
    bne TestForJoystick
    lda #jmpSt_StartJumping
    sta Jumping
    jmp GameLooperEnd    

;*************************************************************************************************************
TestForJoystick
    lda CIAPRA
    eor #%11111111
    sta JoystickState
    and #joystickLeft
    cmp #joystickLeft
    bne @TestRight 
    lda #directionLeft
    sta QuazzyDirection
    jmp UpdateQuazzy

@TestRight
    lda JoystickState
    and #joystickRight
    cmp #joystickRight
    bne @TestUp 
    lda #directionRight
    sta QuazzyDirection
    jmp UpdateQuazzy

@TestUp
    lda JoystickState
    and #joystickUp
    cmp #joystickUp
    bne GameLooperEnd
    lda #jmpSt_StartJumping
    sta Jumping
    jmp UpdateQuazzy

;*************************************************************************************************************
GameLooperEnd
    ;dec $D020
    jsr UpdateSprites

    jmp GameLooper

; --------------------------------------------------------------
UpdateQuazzy
    lda QuazzyDirection
    bmi GoingLeft

    ; Quazzy Going Right
    lda Jumping
    cmp #jmpSt_StartJumping
    bcs @ByPass

    ; Setting Up Quazzy's Animation
    lda QuazzyPreviousDirection
    bpl @ByPass
    SetAnimation QuazzyHiResSprNo,libSprite_ACTIVE,<AnimateQuazzyRightHR,>AnimateQuazzyRightHR,AnimateQuazzyRightHRLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND 
    SetAnimation QuazzyMCSprNo,libSprite_ACTIVE,<AnimateQuazzyRightMC,>AnimateQuazzyRightMC,AnimateQuazzyRightMCLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND 
    lda QuazzyDirection
    sta QuazzyPreviousDirection

@ByPass
    lda #0                              ; X Hi
    ldx #3                              ; X Lo
    ldy #QuazzyHiResSprNo
    jsr AddToX               ; Update Sprite 0 X

    jmp GameLooperEnd

GoingLeft
    ; Quazzy Going Left
    lda Jumping
    cmp #jmpSt_StartJumping
    bcs @ByPass

    ; Setting Up Quazzy's Animation
    lda QuazzyPreviousDirection
    bmi @ByPass
    SetAnimation QuazzyHiResSprNo,libSprite_ACTIVE,<AnimateQuazzyLeftHR,>AnimateQuazzyLeftHR,AnimateQuazzyLeftHRLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND
    SetAnimation QuazzyMCSprNo,libSprite_ACTIVE,<AnimateQuazzyLeftMC,>AnimateQuazzyLeftMC,AnimateQuazzyLeftMCLen,QuazzyFrameDelay,libSprite_LOOPING,libSprite_ONDEMAND
    lda QuazzyDirection
    sta QuazzyPreviousDirection

@ByPass
    lda #0                              ; X Hi
    ldx #3                              ; X Lo
    ldy #QuazzyHiResSprNo
    jsr SubFromX             ; Update Sprite 0 X

    jmp GameLooperEnd

;*************************************************************************************************************
JumpCycle
    lda FrameCounter
    beq @ByPass
    cmp #6
    beq @ByPass
    cmp #12
    beq @ByPass
    cmp #18
    beq @ByPass
    cmp #24
    beq @ByPass
    rts

@ByPass
    inc JumpIndex
    ldx JumpIndex
    cpx #12
    bne Jump
    jmp EndJump

Jump
    lda JumpArk,x
    bmi SubY

    tax
    lda #0                              ; Y
    ldy #QuazzyHiResSprNo
    jsr AddToY

    jmp jumpDone

SubY
    ; 2's Comp
    eor #$FF
    clc
    adc #1

    tax
    lda #0
    ldy #QuazzyHiResSprNo
    jsr SubFromY             ; Update Sprite 0 Y

jumpDone
    lda QuazzyDirection
    bmi LeftAni
    lda Jumping
    cmp #jmpSt_StartJumping 
    beq @SetAni
    lda QuazzyPreviousDirection
    bmi @SetAni
    jmp JumpRet

@SetAni
    SetAnimation QuazzyHiResSprNo,libSprite_ACTIVE,<JumpAnimationRightHR,>JumpAnimationRightHR,JumpAnimationRightHRLen,QuazzyJumpFrameDelay,libSprite_ONCE,libSprite_CONSTANT 
    SetAnimation QuazzyMCSprNo,libSprite_ACTIVE,<JumpAnimationRightMC,>JumpAnimationRightMC,JumpAnimationRightMCLen,QuazzyJumpFrameDelay,libSprite_ONCE,libSprite_CONSTANT 
    lda QuazzyDirection
    sta QuazzyPreviousDirection
    lda #jmpSt_InFlight 
    sta Jumping
    jmp JumpRet

LeftAni
    lda Jumping
    cmp #jmpSt_StartJumping 
    beq @SetAni
    lda QuazzyPreviousDirection
    bmi JumpRet

@SetAni
    SetAnimation QuazzyHiResSprNo,libSprite_ACTIVE,<JumpAnimationLeftHR,>JumpAnimationLeftHR,JumpAnimationLeftHRLen,QuazzyJumpFrameDelay,libSprite_ONCE,libSprite_CONSTANT
    SetAnimation QuazzyMCSprNo,libSprite_ACTIVE,<JumpAnimationLeftMC,>JumpAnimationLeftMC,JumpAnimationLeftMCLen,QuazzyJumpFrameDelay,libSprite_ONCE,libSprite_CONSTANT
    lda QuazzyDirection
    sta QuazzyPreviousDirection
    lda #jmpSt_InFlight 
    sta Jumping

JumpRet
    rts

EndJump
    lda #jmpSt_NotJumping
    sta JumpIndex
    sta Jumping
    lda QuazzyPreviousDirection
    eor #$FF
    sta QuazzyPreviousDirection
    rts

;*************************************************************************************************************
HELLOWORLD
    byte 17, 17, 17, 17
    text "hello my name is quazzy osbourne :)"  ; the string to print
    byte 00             ; The terminator character

* = $2A80 ; "Sprite Date"
incbin "spritesV3.bin"
