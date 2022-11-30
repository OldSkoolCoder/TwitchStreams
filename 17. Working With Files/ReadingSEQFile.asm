BasicUpstart2(main)

.label CHROUT  = $FFD2
.label CHKOUT  = $FFC9
.label OPEN    = $FFC0
.label SETLFS  = $FFBA
.label SETNAM  = $FFBD
.label CLRCHN  = $FFCC
.label CLOSE   = $FFC3
.label PRINTSTRING = $AB1E
.label CHRIN   = $FFCF
.label CHKIN   = $FFC6

.encoding "petscii_mixed"

FILENAMEDISK:
    .text "setup2,s,r"
FILENAMEDISKEND:
    brk

MountDiskPrompt:
    .text "mount the disk?"
    brk

main:
    ldx #$00
    lda #<MountDiskPrompt
    ldy #>MountDiskPrompt
    jsr PRINTSTRING
    jsr CHRIN

    lda #13
    jsr CHROUT

    lda #1      // Logical File Number
    ldx #8      // Device Number (Disk Drive 8)
    ldy #2      // Secondary Address
    jsr SETLFS  // open 1,8,2 
    lda #FILENAMEDISKEND - FILENAMEDISK // Filename Length
    ldx #<FILENAMEDISK  // Lo Byte of Filename address
    ldy #>FILENAMEDISK  // Hi Byte of the Filename address
    jsr SETNAM  // ,"setup,s,r"
    jsr OPEN

    ldx #1      // Logical File Number
    jsr CHKIN

Looper:
    jsr CHRIN
    tax
    lda $90
    and #$40
    bne !WeAreDone+
    txa
    //cmp #255
    //beq !WeAreDone+
    jsr CHROUT
    jmp Looper

!WeAreDone:
    jsr CLRCHN
    lda #1      // Logical File Number
    jsr CLOSE
    rts