#importonce

BasicUpstart2(Main)

GameState: .byte 0

State:
{
    .label IDLE         = 0
    .label GoingRIGHT   = 1
    .label GoingLEFT    = 2
    .label GoingUP      = 3 
    .label GoingDOWN    = 4
    .label INIT         = 5
}

.label GameStateIndirectJump = $FB


Main:
    lda #State.INIT
    sta GameState
    jmp StateMachineLooper

StateMachineLooper:
    ldx #200
!RasterLooper:
    cpx $D012              // Compare A to current raster line
    bne !RasterLooper-

    lda GameState
    asl
    tay
    lda GameStateJumpArray,y
    sta GameStateIndirectJump
    iny
    lda GameStateJumpArray,y
    sta GameStateIndirectJump + 1

    // ON State GOSUB 1111, 2222, 3333, 4444, 5555, 6666
    jsr GameStateSubRoutine
    jmp StateMachineLooper

ReturnToSender:
    rts

GameStateSubRoutine:
    jmp (GameStateIndirectJump)

GameStateJumpArray:
    // IDLE
    .word StateIDLE
    // RIGHT
    .word StateRIGHT
    // LEFT
    .word StateLEFT
    // UP
    .word StateUP
    // DOWN
    .word StateDOWN
    // INIT
    .word StateINIT

StateINIT:
{
    ldy #64
    lda #255
!Looper:
    sta $3000,y
    dey
    bpl !Looper-

    lda #192
    sta $07f8
    lda #%00000001
    sta $D015           // Enabled SP0
    lda #100
    sta $D000
    sta $D001

    lda #State.IDLE
    sta GameState
    rts
}

StateIDLE:
{
    lda $C5         // 197 Kernal ScanKeyCode
    cmp #64         // No Key Pressed
    beq !Exit+

    cmp #9          // W = UP
    bne !NextKeyTest+
    lda #State.GoingUP
    jmp !UpdatteState+

!NextKeyTest:
    cmp #13          // S = DOWN
    bne !NextKeyTest+
    lda #State.GoingDOWN
    jmp !UpdatteState+

!NextKeyTest:
    cmp #10          // A = LEFT
    bne !NextKeyTest+
    lda #State.GoingLEFT
    jmp !UpdatteState+

!NextKeyTest:
    cmp #18          // D = RIGHT
    bne !Exit+
    lda #State.GoingRIGHT

!UpdatteState:
    sta GameState
!Exit:
    rts
}

StateRIGHT:
{
    inc $D000
    lda #State.IDLE
    sta GameState
    rts
}

StateLEFT:
{
    dec $D000
    lda #State.IDLE
    sta GameState
    rts
}

StateUP:
{
    dec $D001
    lda #State.IDLE
    sta GameState
    rts
}


StateDOWN:
{
    inc $D001
    lda #State.IDLE
    sta GameState
    rts
}