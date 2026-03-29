.segment "HEADER"
    .byte "N", "E", "S", $1A
    .byte $02
    .byte $01
    .byte $00
    .byte $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00

.segment "ZEROPAGE"
frame_ready: .res 1

.segment "CODE"

.proc Reset
    sei
    cld

    ldx #$40
    stx $4017

    ldx #$FF
    txs

    ldx #$00
    stx $2000
    stx $2001
    stx $4010

    bit $2002

WaitVBlank1:
    bit $2002
    bpl WaitVBlank1

WaitVBlank2:
    bit $2002
    bpl WaitVBlank2

    lda #$00
    sta frame_ready

    lda #$FE
    ldx #$00
ClearOAM:
    sta $0200, x
    inx
    bne ClearOAM

    lda #120
    sta $0200
    lda #$01
    sta $0201
    lda #$00
    sta $0202
    lda #120
    sta $0203

    jsr LoadPalettes
    jsr ClearNametable0

    lda #$00
    sta $2005
    sta $2005

    lda #%10000000
    sta $2000

    lda #%00011000
    sta $2001

MainLoop:
    lda frame_ready
    beq MainLoop
    lda #$00
    sta frame_ready
    jmp MainLoop
.endproc

.proc LoadPalettes
    bit $2002
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

    ldx #$00
LoadPaletteLoop:
    lda PaletteData, x
    sta $2007
    inx
    cpx #$20
    bne LoadPaletteLoop
    rts
.endproc

.proc ClearNametable0
    bit $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006

    lda #$00
    ldx #$04
ClearNTPages:
    ldy #$00
ClearNTRow:
    sta $2007
    iny
    bne ClearNTRow
    dex
    bne ClearNTPages

    ldx #$40
ClearAttr:
    sta $2007
    dex
    bne ClearAttr
    rts
.endproc

.proc NMI
    lda #$00
    sta $2003
    lda #$02
    sta $4014

    lda #$01
    sta frame_ready
    rti
.endproc

.proc IRQ
    rti
.endproc

PaletteData:
    .byte $21, $00, $10, $20
    .byte $0F, $16, $27, $30
    .byte $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F
    .byte $21, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F
    .byte $0F, $0F, $0F, $0F

.segment "VECTORS"
    .word NMI
    .word Reset
    .word IRQ

.segment "CHR"

    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

    .byte %00011000
    .byte %00111100
    .byte %01111110
    .byte %11111111
    .byte %11111111
    .byte %01111110
    .byte %00100100
    .byte %01000010
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

    .res $2000 - 32