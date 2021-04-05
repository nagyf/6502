    .org $8000

    .include "lcd.s"

reset:
    ; Entry point & reset vector
    ; This is the subroutine that is executed when reset, also the first boot starts with this
    ldx #$ff        ; Setup stack pointer
    txs

    jsr lcd_init    ; Initialize LCD display

    lda message
    jsr lcd_print_message

loop:
    jmp loop

    .org $fffc
    .word reset
    .word $0000
