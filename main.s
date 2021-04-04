PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E = %10000000
RW = %01000000
RS = %00100000

    .org $8000

lcd_init:
    ; Initialize the LCD module
    lda #%11111111 ; Set all pins on port B to output
    sta DDRB
    
    lda #%11100000 ; Set top 3 pins on port A to output
    sta DDRA

    lda #%00111000 ; Set 8-bit mode, 2 line display, 5x8 font
    jsr lcd_command

    lda #%00001110 ; Display on, cursor on, blink off
    jsr lcd_command
 
    lda #%00000110 ; Increment and shift cursor; dont shift display
    jsr lcd_command

    lda #%00000001 ; Clear display
    jsr lcd_command

    lda #%00000010 ; Return home
    jsr lcd_command

    rts

lcd_wait:
    ; Waits until LCD busy flag is set
    ; Necessary for working with the LCD, this needs to be called after each command
    pha             ; Save the A register status
    lda #%00000000  ; Setup PortB for reading
    sta DDRB
lcdbusy:
    lda #%00000000  ; Setup PortB for reading
    sta DDRB

    lda #RW
    sta PORTA
    lda #(RW | E)
    sta PORTA

    lda PORTB       ; Read from PORTB
    and #%10000000  ; Only keep the busy flag. This will set the processor Zero flag
    bne lcdbusy     ; Loop until busy flag is set

    lda #RW
    sta PORTA
    lda #%11111111  ; Revert PortB for output
    sta DDRB

    pla             ; Restore the A register status
    rts

lcd_command:
    ; Sends a command to the LCD module
    sta PORTB
    lda #0
    sta PORTA
    lda #E
    sta PORTA
    lda #0
    sta PORTA

    jsr lcd_wait    ; Wait for the command to fully execute

    rts

lcd_print_char:
    sta PORTB
    lda #RS         ; Clear  RS/RW/E bits
    sta PORTA
    lda #(RS | E)   ; Set E bit to send instruction
    sta PORTA
    lda #RS         ; Clear  RS/RW/E bits
    sta PORTA
    rts

lcd_print_message:
    ; Prints a null terminated string to the LCD screen
    ; Expects the memory address of the message in A register
    ldx #0
print:
    lda message,x
    beq print_end   ; Last character in a message is the zero byte. When we encounter it, exit the loop
    jsr lcd_print_char
    inx
    jmp print 
print_end:
    rts

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

message: .asciiz "Szia Marcsi!"

    .org $fffc
    .word reset
    .word $0000
