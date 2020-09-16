#import "Constants.asm"

.const JoyUp    = %00000001
.const JoyDown  = %00000010
.const JoyLeft  = %00000100
.const JoyRight = %00001000
.const JoyFire  = %00010000

.const JoyMask  = %00011111

.const CoolDownDefault = 30

.namespace libJoyStick
{
    .label JoyStickPort2    = CIAPRA
    .label JoyStickPort1    = CIAPRB

    ReadJoySticks:
    {
        lda JoyStickPort2
        eor #$FF                // Inverts the Bits
        and #JoyMask            // Mask Off only important Bits
        sta libJoy2.JoyStickInputThisFrame
        jsr libJoy2.BounceCheck

        lda JoyStickPort1
        eor #$FF                // Inverts the Bits
        and #JoyMask            // Mask Off only important Bits
        sta libJoy1.JoyStickInputThisFrame
        jsr libJoy1.BounceCheck
        rts
    }

    .namespace libJoy2
    {
        JoyStickInputThisFrame:
            .byte 0

        JoystickInputFromLastFrame:
            .byte 0

        JoystickDifferenceFromLastFrame:
            .byte 0

        FireCoolDown:
            .byte 0

        BounceCheck:
        {
            lda JoyStickInputThisFrame
            eor JoystickInputFromLastFrame
            sta JoystickDifferenceFromLastFrame

//          00101
//          00001 eor  
//          -----
//          00100 = Difference

            lda FireCoolDown        // Load Cool Down
            beq !CoolDownFinish+    // Coll Down finished
            dec FireCoolDown        // Nope, 

        !CoolDownFinish:
            lda JoyStickInputThisFrame
            sta JoystickInputFromLastFrame
            rts
        }

        CheckUp:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyUp
            cmp #JoyUp
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            sec                     // Triggered
            rts    
            
        }

        CheckDown:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyDown
            cmp #JoyDown
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            sec                     // Triggered
            rts    
            
        }

        CheckRight:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyRight
            cmp #JoyRight
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            sec                     // Triggered
            rts    
            
        }

        CheckLeft:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyLeft
            cmp #JoyLeft
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            sec                     // Triggered
            rts    
        }

        CheckFire:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyFire
            cmp #JoyFire
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            lda FireCoolDown
            beq !OkToFire+          // Cool Down Completed?
            clc                     // Not Triggered
            rts
        !OkToFire:
            lda CoolDownDefault
            sta FireCoolDown        // Reset Cool Down
            sec                     // Fire Triggered
            rts    
        }
    }

    .namespace libJoy1
    {
        JoyStickInputThisFrame:
            .byte 0

        JoystickInputFromLastFrame:
            .byte 0

        FireCoolDown:
            .byte 0

        JoystickDifferenceFromLastFrame:
            .byte 0

        BounceCheck:
        {
            lda JoyStickInputThisFrame
            eor JoystickInputFromLastFrame
            sta JoystickDifferenceFromLastFrame

//          00101
//          00001 eor  
//          -----
//          00100 = Difference

            lda FireCoolDown
            beq !CoolDownFinish+
            dec FireCoolDown  

        !CoolDownFinish:
            lda JoyStickInputThisFrame
            sta JoystickInputFromLastFrame
            rts
        }

        CheckUp:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyUp
            cmp #JoyUp
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            sec                     // Triggered
            rts    
            
        }

        CheckDown:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyDown
            cmp #JoyDown
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            sec                     // Triggered
            rts    
            
        }

        CheckRight:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyRight
            cmp #JoyRight
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            sec                     // Triggered
            rts    
            
        }

        CheckLeft:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyLeft
            cmp #JoyLeft
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            sec                     // Triggered
            rts    
        }

        CheckFire:
        {
            // Result carry Set if triggered, else carry is clear
            lda JoyStickInputThisFrame
            and #JoyFire
            cmp #JoyFire
            beq !Is+
            clc                     // Not Triggered
            rts
        !Is:
            lda FireCoolDown
            beq !OkToFire+          // Cool Down Completed?
            clc                     // Not Triggered
            rts
        !OkToFire:
            lda CoolDownDefault
            sta FireCoolDown        // Reset Cool Down
            sec                     // Fire Triggered
            rts    
       }
    }
}