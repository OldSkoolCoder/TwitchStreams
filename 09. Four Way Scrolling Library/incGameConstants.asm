#importonce

.label SCREEN_MEM   = $4000
.label SCREEN1_MEM  = $4000                 // Bank 1 - Screen 0 // $4000
.label SCREEN2_MEM  = $4400                 // Bank 1 - Screen 1 // $4400
.label SCORE_SCREEN = $5800                 // Bank 1 - Screen 6 // $5800

.label COLOR_MEM  = $D800                   // Color mem never changes
.label CHAR_MEM   = $4800                   // Base of character set memory (set 1)
.label SPRITE_MEM = $5C00                   // Base of sprite memory

.label COLOR_DIFF = COLOR_MEM - SCREEN_MEM  // difference between color and screen ram
                                            // a workaround for CBM PRG STUDIOs poor
                                            // expression handling

.label SPRITE_POINTER_BASE = SCREEN_MEM + $3f8 // last 8 bytes of screen mem

.label SPRITE_BASE = $70                       // the pointer to the first image#

.label SPRITE_0_PTR = SPRITE_POINTER_BASE + 0  // Sprite pointers
.label SPRITE_1_PTR = SPRITE_POINTER_BASE + 1
.label SPRITE_2_PTR = SPRITE_POINTER_BASE + 2
.label SPRITE_3_PTR = SPRITE_POINTER_BASE + 3
.label SPRITE_4_PTR = SPRITE_POINTER_BASE + 4
.label SPRITE_5_PTR = SPRITE_POINTER_BASE + 5
.label SPRITE_6_PTR = SPRITE_POINTER_BASE + 6
.label SPRITE_7_PTR = SPRITE_POINTER_BASE + 7

.label SPRITE_DELTA_OFFSET_X = 8               // Offset from SPRITE coords to Delta Char coords
.label SPRITE_DELTA_OFFSET_Y = 14

.label NUMBER_OF_SPRITES_DIV_4 = 3              // This is for my personal version, which
                                                // loads sprites and characters under IO ROM

.label LEVEL_1_MAP   = $E000                    //Address of level 1 tiles/charsets
.label LEVEL_1_CHARS = $E800


.label PARAM1 = $03                 // These will be used to pass parameters to routines
.label PARAM2 = $04                 // when you can't use registers or other reasons
.label PARAM3 = $05                            
.label PARAM4 = $06                 // essentially, think of these as extra data registers
.label PARAM5 = $07

.label TIMER = $08                  // Timers - fast and slow, updated every frame
.label SLOW_TIMER = $09

.label WPARAM1 = $0A                // Word length Params. Same as above only room for 2
.label WPARAM2 = $0C                // bytes (or an address)
.label WPARAM3 = $0E

//---------------------------- $11 - $16 available

.label ZEROPAGE_POINTER_1 = $17     // Similar only for pointers that hold a word long address
.label ZEROPAGE_POINTER_2 = $19
.label ZEROPAGE_POINTER_3 = $21
.label ZEROPAGE_POINTER_4 = $23

.label CURRENT_SCREEN   = $25       // Pointer to current front screen
.label CURRENT_BUFFER   = $27       // Pointer to current back buffer

.label SCROLL_COUNT_X   = $29       // Current hardware scroll value
.label SCROLL_COUNT_Y   = $2A
.label SCROLL_SPEED     = $2B       // Scroll speed (not implemented yet)
.label SCROLL_DIRECTION = $2C       // Direction we are scrolling in
.label SCROLL_MOVING    = $2D       // are we moving? (Set to direction of scrolling)
                                    // This is for resetting back to start frames

                                    // All data is for the top left corner of the visible map area
.label MAP_POS_ADDRESS = $2E       // (2 bytes) pointer to current address in the level map
.label MAP_X_POS       = $30       // Current map x position (in tiles)
.label MAP_Y_POS       = $31       // Current map y position (in tiles)
.label MAP_X_DELTA     = $32       // Map sub tile delta (in characters)
.label MAP_Y_DELTA     = $33       // Map sub tile delta (in characters)
