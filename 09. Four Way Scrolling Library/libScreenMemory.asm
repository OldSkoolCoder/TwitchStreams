#import "libMacros.asm"
#import "incGameConstants.asm"
//===============================================================================
//                                                               SCREEN ROUTINES
//===============================================================================
//                                                            Peter 'Sig' Hewett
//                                                                   - 2016/2017
//-------------------------------------------------------------------------------
//                                                               SWAP SCREENS
//-------------------------------------------------------------------------------
// Exchange the front and backbuffer screens
//-------------------------------------------------------------------------------
SwapScreens:
{
        lda CURRENT_SCREEN + 1             // load hi .byte of current screen
        cmp #>SCREEN2_MEM
        beq !screen2+

        loadZPPointer(CURRENT_SCREEN, SCREEN2_MEM)
        loadZPPointer(CURRENT_BUFFER, SCREEN1_MEM)
        rts

    !screen2:
        loadZPPointer(CURRENT_SCREEN, SCREEN1_MEM)
        loadZPPointer(CURRENT_BUFFER, SCREEN2_MEM)
        rts
}
//===================================================================================================
//                                                                      FETCH PLAYFIELD LINE ADDRESS
//===================================================================================================
// A helper routine to return the line address for the current front screen only. A cut back version
// of FetchLineAddress for faster use with sprite/character collisions it also uses the Y register
// instead of the X as that is tied up in our collision routines to hold the sprite number
//
// Y = line number
// Returns : ZEROPAGE_POINTER_1 = screen line address
// Modifies A
//---------------------------------------------------------------------------------------------------
FetchPlayfieldLineAddress:
{
        lda CURRENT_SCREEN + 1          // load HI .byte of curren screen address
        cmp #>SCREEN1_MEM               // compare it to the HI .byte of SCREEN1_MEM
        beq !screen1+                   // if it's equal - it's screen1 
                                        // otherwise it's screen2

        lda SCREEN2_LINE_OFFSET_TABLE_LO,y      // Use Y to lookup the address and save it in
        sta ZEROPAGE_POINTER_1                  // ZEROPAGE_POINTER_1
        lda SCREEN2_LINE_OFFSET_TABLE_HI,y
        sta ZEROPAGE_POINTER_1 + 1
        rts

!screen1:
        lda SCREEN1_LINE_OFFSET_TABLE_LO,y      // Use Y to lookup the address and save it in
        sta ZEROPAGE_POINTER_1                  // ZEROPAGE_POINTER_1
        lda SCREEN1_LINE_OFFSET_TABLE_HI,y
        sta ZEROPAGE_POINTER_1 + 1
        rts
}

//-------------------------------------------------------------------------------
//                                                           FETCH LINE ADDRESS
//-------------------------------------------------------------------------------
// A helper routine to return the line address for the correct screen to draw to
// Given the screen base in WPARAM1, and the line in X (Y coord) we test
// the high .byte in WPARAM1 and use the correct lookup table to get the line
// address, returning it in ZEROPAGE_POINTER_1

// An additional 'jump in' point "FetchScreenLineAddress" can be used that will
// only consider the CURRENT_SCREEN pointer, likewise "FetchBufferLineAddress"
// will jump in and substitute the current buffer.
//
// X - Line required
//
// returns ZEROPAGE_POINTER_1
//
// Modifies A
//
//-------------------------------------------------------------------------------
GetLineAddress:
{
        lda WPARAM1 + 1
        jmp detectScreen

    GetScreenLineAddress:
        lda CURRENT_SCREEN + 1
        jmp detectScreen

    FetchBufferLineAddress:
        lda CURRENT_BUFFER + 1

    detectScreen:
        cmp #>SCREEN1_MEM
        beq !screen1+
        cmp #>SCREEN2_MEM
        beq !screen2+                                        // if none of the above, it will default to Screen1
        cmp #>SCORE_SCREEN
        beq !score+


    !screen1:
        lda SCREEN1_LINE_OFFSET_TABLE_LO,x
        sta ZEROPAGE_POINTER_1
        lda SCREEN1_LINE_OFFSET_TABLE_HI,x
        sta ZEROPAGE_POINTER_1 + 1
        rts
    !screen2:
        lda SCREEN2_LINE_OFFSET_TABLE_LO,x
        sta ZEROPAGE_POINTER_1
        lda SCREEN2_LINE_OFFSET_TABLE_HI,x
        sta ZEROPAGE_POINTER_1 + 1
        rts

    !score:
        lda SCORE_LINE_OFFSET_TABLE_LO,x
        sta ZEROPAGE_POINTER_1
        lda SCORE_LINE_OFFSET_TABLE_HI,x
        sta ZEROPAGE_POINTER_1 + 1
        rts
}


//-------------------------------------------------------------------------------
//                                                               CLEAR SCREEN
//-------------------------------------------------------------------------------
//
// Clears the screen using a chosen character.
// A = Character/Color to clear the screen with
//
// Modifies X
//-------------------------------------------------------------------------------
ClearScreen1:
{
        ldx #$00
    !clearLoop:
        sta SCREEN1_MEM,x
        sta SCREEN1_MEM + 250,x
        sta SCREEN1_MEM + 500,x                 // Game screen only goes to 720
        sta SCREEN1_MEM + 750,x
        inx
        cpx #250
        bne !clearLoop-
        rts
}

ClearScreen2:
{
        ldx #$00
    !clearLoop:
        sta SCREEN2_MEM,x
        sta SCREEN2_MEM + 250,x
        sta SCREEN2_MEM + 500,x                 // Game screen only goes to 720
        sta SCREEN2_MEM + 750,x
        inx
        cpx #250
        bne !clearLoop-
        rts
}

ClearScoreScreen:
{
        ldx #$00
    !clearLoop:
        sta SCORE_SCREEN,x
        sta SCORE_SCREEN + 250,x
        sta SCORE_SCREEN + 500,x
        sta SCORE_SCREEN + 750,x
        inx
        cpx #250
        bne !clearLoop-
        rts
}

ClearColorRam:
{
        ldx #$00
    !clearLoop:
        sta COLOR_MEM,x
        sta COLOR_MEM + 250,x
        sta COLOR_MEM + 500,x
        sta COLOR_MEM + 750,x
        inx
        cpx #250
        bne !clearLoop-
        rts
}

//-------------------------------------------------------------------------------
//                                                         COPY TO BUFFER (SLOW)
//-------------------------------------------------------------------------------
// NOTE : Don't use this for scrolling. Use the unrolled version in scrolling.asm
// this is just for setup purposes. It takes the current front screen and copys
// it to the buffer
//--------------------------------------------------------------------------------
CopyToBuffer:
{
        ldx #$00
    !loop1:
        lda SCREEN1_MEM,x
        sta SCREEN2_MEM,x

        lda SCREEN1_MEM + 250,x
        sta SCREEN2_MEM + 250,x
        
        lda SCREEN1_MEM + 500,x
        sta SCREEN2_MEM + 500,x

        lda SCREEN1_MEM + 750,x                 // Game screen only goes to 720
        sta SCREEN2_MEM + 750,x        
        inx
        cpx #250
        bne !loop1-
        rts
}


// Screen Line Offset Tables
// Query a line with lda (POINTER TO TABLE),x (where x holds the line number)
// and it will return the screen address for that line

// C64 PRG STUDIO has a lack of expression support that makes creating some tables very problematic
// Be aware that you can only use ONE expression after a defined constant, no braces, and be sure to
// account for order of precedence.

// For these tables you MUST have the Operator Calc directive set at the top of your main file
// or have it checked in options or BAD THINGS WILL HAPPEN!! It basically means that calculations
// will be performed BEFORE giving back the hi/lo .byte with '>' rather than the default of
// hi/lo .byte THEN the calculation

SCREEN_LINE_OFFSET_TABLE_LO:
SCREEN1_LINE_OFFSET_TABLE_LO:
    .byte <SCREEN_MEM
    .byte <SCREEN_MEM + 40
    .byte <SCREEN_MEM + 80
    .byte <SCREEN_MEM + 120
    .byte <SCREEN_MEM + 160
    .byte <SCREEN_MEM + 200
    .byte <SCREEN_MEM + 240
    .byte <SCREEN_MEM + 280
    .byte <SCREEN_MEM + 320
    .byte <SCREEN_MEM + 360
    .byte <SCREEN_MEM + 400
    .byte <SCREEN_MEM + 440
    .byte <SCREEN_MEM + 480
    .byte <SCREEN_MEM + 520
    .byte <SCREEN_MEM + 560
    .byte <SCREEN_MEM + 600
    .byte <SCREEN_MEM + 640
    .byte <SCREEN_MEM + 680
    .byte <SCREEN_MEM + 720
    .byte <SCREEN_MEM + 760
    .byte <SCREEN_MEM + 800
    .byte <SCREEN_MEM + 840
    .byte <SCREEN_MEM + 880
    .byte <SCREEN_MEM + 920
    .byte <SCREEN_MEM + 960

SCREEN_LINE_OFFSET_TABLE_HI:
SCREEN1_LINE_OFFSET_TABLE_HI:
    .byte >SCREEN_MEM
    .byte >SCREEN_MEM + 40
    .byte >SCREEN_MEM + 80
    .byte >SCREEN_MEM + 120
    .byte >SCREEN_MEM + 160
    .byte >SCREEN_MEM + 200
    .byte >SCREEN_MEM + 240
    .byte >SCREEN_MEM + 280
    .byte >SCREEN_MEM + 320
    .byte >SCREEN_MEM + 360
    .byte >SCREEN_MEM + 400
    .byte >SCREEN_MEM + 440
    .byte >SCREEN_MEM + 480
    .byte >SCREEN_MEM + 520
    .byte >SCREEN_MEM + 560
    .byte >SCREEN_MEM + 600
    .byte >SCREEN_MEM + 640
    .byte >SCREEN_MEM + 680
    .byte >SCREEN_MEM + 720
    .byte >SCREEN_MEM + 760
    .byte >SCREEN_MEM + 800
    .byte >SCREEN_MEM + 840
    .byte >SCREEN_MEM + 880
    .byte >SCREEN_MEM + 920
    .byte >SCREEN_MEM + 960

SCREEN2_LINE_OFFSET_TABLE_LO:       
    .byte <SCREEN2_MEM
    .byte <SCREEN2_MEM + 40
    .byte <SCREEN2_MEM + 80
    .byte <SCREEN2_MEM + 120
    .byte <SCREEN2_MEM + 160
    .byte <SCREEN2_MEM + 200
    .byte <SCREEN2_MEM + 240
    .byte <SCREEN2_MEM + 280
    .byte <SCREEN2_MEM + 320
    .byte <SCREEN2_MEM + 360
    .byte <SCREEN2_MEM + 400
    .byte <SCREEN2_MEM + 440
    .byte <SCREEN2_MEM + 480
    .byte <SCREEN2_MEM + 520
    .byte <SCREEN2_MEM + 560
    .byte <SCREEN2_MEM + 600
    .byte <SCREEN2_MEM + 640
    .byte <SCREEN2_MEM + 680
    .byte <SCREEN2_MEM + 720
    .byte <SCREEN2_MEM + 760
    .byte <SCREEN2_MEM + 800
    .byte <SCREEN2_MEM + 840
    .byte <SCREEN2_MEM + 880
    .byte <SCREEN2_MEM + 920
    .byte <SCREEN2_MEM + 960

SCREEN2_LINE_OFFSET_TABLE_HI:
    .byte >SCREEN2_MEM
    .byte >SCREEN2_MEM + 40
    .byte >SCREEN2_MEM + 80
    .byte >SCREEN2_MEM + 120
    .byte >SCREEN2_MEM + 160
    .byte >SCREEN2_MEM + 200
    .byte >SCREEN2_MEM + 240
    .byte >SCREEN2_MEM + 280
    .byte >SCREEN2_MEM + 320
    .byte >SCREEN2_MEM + 360
    .byte >SCREEN2_MEM + 400
    .byte >SCREEN2_MEM + 440
    .byte >SCREEN2_MEM + 480
    .byte >SCREEN2_MEM + 520
    .byte >SCREEN2_MEM + 560
    .byte >SCREEN2_MEM + 600
    .byte >SCREEN2_MEM + 640
    .byte >SCREEN2_MEM + 680
    .byte >SCREEN2_MEM + 720
    .byte >SCREEN2_MEM + 760
    .byte >SCREEN2_MEM + 800
    .byte >SCREEN2_MEM + 840
    .byte >SCREEN2_MEM + 880
    .byte >SCREEN2_MEM + 920
    .byte >SCREEN2_MEM + 960

COLOR_LINE_OFFSET_TABLE_LO:
    .byte <COLOR_MEM
    .byte <COLOR_MEM + 40
    .byte <COLOR_MEM + 80
    .byte <COLOR_MEM + 120
    .byte <COLOR_MEM + 160
    .byte <COLOR_MEM + 200
    .byte <COLOR_MEM + 240
    .byte <COLOR_MEM + 280
    .byte <COLOR_MEM + 320
    .byte <COLOR_MEM + 360
    .byte <COLOR_MEM + 400
    .byte <COLOR_MEM + 440
    .byte <COLOR_MEM + 480
    .byte <COLOR_MEM + 520
    .byte <COLOR_MEM + 560
    .byte <COLOR_MEM + 600
    .byte <COLOR_MEM + 640
    .byte <COLOR_MEM + 680
    .byte <COLOR_MEM + 720
    .byte <COLOR_MEM + 760
    .byte <COLOR_MEM + 800
    .byte <COLOR_MEM + 840
    .byte <COLOR_MEM + 880
    .byte <COLOR_MEM + 920
    .byte <COLOR_MEM + 960

COLOR_LINE_OFFSET_TABLE_HI:
    .byte >COLOR_MEM
    .byte >COLOR_MEM + 40
    .byte >COLOR_MEM + 80
    .byte >COLOR_MEM + 120
    .byte >COLOR_MEM + 160
    .byte >COLOR_MEM + 200
    .byte >COLOR_MEM + 240
    .byte >COLOR_MEM + 280
    .byte >COLOR_MEM + 320
    .byte >COLOR_MEM + 360
    .byte >COLOR_MEM + 400
    .byte >COLOR_MEM + 440
    .byte >COLOR_MEM + 480
    .byte >COLOR_MEM + 520
    .byte >COLOR_MEM + 560
    .byte >COLOR_MEM + 600
    .byte >COLOR_MEM + 640
    .byte >COLOR_MEM + 680
    .byte >COLOR_MEM + 720
    .byte >COLOR_MEM + 760
    .byte >COLOR_MEM + 800
    .byte >COLOR_MEM + 840
    .byte >COLOR_MEM + 880
    .byte >COLOR_MEM + 920
    .byte >COLOR_MEM + 960

SCORE_LINE_OFFSET_TABLE_LO:
    .byte <SCORE_SCREEN
    .byte <SCORE_SCREEN + 40
    .byte <SCORE_SCREEN + 80
    .byte <SCORE_SCREEN + 120
    .byte <SCORE_SCREEN + 160
    .byte <SCORE_SCREEN + 200
    .byte <SCORE_SCREEN + 240
    .byte <SCORE_SCREEN + 280
    .byte <SCORE_SCREEN + 320
    .byte <SCORE_SCREEN + 360
    .byte <SCORE_SCREEN + 400
    .byte <SCORE_SCREEN + 440
    .byte <SCORE_SCREEN + 480
    .byte <SCORE_SCREEN + 520
    .byte <SCORE_SCREEN + 560
    .byte <SCORE_SCREEN + 600
    .byte <SCORE_SCREEN + 640
    .byte <SCORE_SCREEN + 680
    .byte <SCORE_SCREEN + 720
    .byte <SCORE_SCREEN + 760
    .byte <SCORE_SCREEN + 800
    .byte <SCORE_SCREEN + 840
    .byte <SCORE_SCREEN + 880
    .byte <SCORE_SCREEN + 920
    .byte <SCORE_SCREEN + 960

SCORE_LINE_OFFSET_TABLE_HI:
    .byte >SCORE_SCREEN
    .byte >SCORE_SCREEN + 40
    .byte >SCORE_SCREEN + 80
    .byte >SCORE_SCREEN + 120
    .byte >SCORE_SCREEN + 160
    .byte >SCORE_SCREEN + 200
    .byte >SCORE_SCREEN + 240
    .byte >SCORE_SCREEN + 280
    .byte >SCORE_SCREEN + 320
    .byte >SCORE_SCREEN + 360
    .byte >SCORE_SCREEN + 400
    .byte >SCORE_SCREEN + 440
    .byte >SCORE_SCREEN + 480
    .byte >SCORE_SCREEN + 520
    .byte >SCORE_SCREEN + 560
    .byte >SCORE_SCREEN + 600
    .byte >SCORE_SCREEN + 640
    .byte >SCORE_SCREEN + 680
    .byte >SCORE_SCREEN + 720
    .byte >SCORE_SCREEN + 760
    .byte >SCORE_SCREEN + 800
    .byte >SCORE_SCREEN + 840
    .byte >SCORE_SCREEN + 880
    .byte >SCORE_SCREEN + 920
    .byte >SCORE_SCREEN + 960
