.segment "HEADER"
.byte "N", "E", "S", $1A
.byte $02
.byte $01
.byte $00
.byte $00
.byte $00,$00,$00,$00,$00,$00,$00,$00

.segment "ZEROPAGE"
frame_ready: .res 1

.segment "CODE"

.proc Reset
    sei
    cld

    ldx #$40
    stx $4017

    ldx #$ff
    txs

    inx
    stx $2000
    stx $2001
    stx $4010

; wait for first vblank
vblankwait1:
    bit $2002
    bpl vblankwait1

; set palette at $3F00
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

; universal background color
    lda #$01
    sta $2007

; sprite palette 0
    lda #$0F
    sta $2007
    lda #$16
    sta $2007
    lda #$27
    sta $2007
    lda #$38
    sta $2007

; set up sprite in CPU RAM at $0200
    lda #120      ; Y
    sta $0200
    lda #$00      ; tile index
    sta $0201
    lda #$00      ; attributes
    sta $0202
    lda #120      ; X
    sta $0203

; hide rest of sprites
    ldx #$04
ClearSprites:
    lda #$FE
    sta $0200,x
    inx
    bne ClearSprites

; enable NMI, background, sprites
    lda #%10000000
    sta $2000

    lda #%00011000
    sta $2001

Forever:
    lda frame_ready
    beq Forever
    lda #0
    sta frame_ready
    jmp Forever
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

.segment "VECTORS"
.word NMI
.word Reset
.word IRQ

.segment "CHR"
; tile 0 = simple 8x8 ship-ish block
.byte %00011000
.byte %00111100
.byte %01111110
.byte %11111111
.byte %11111111
.byte %01111110
.byte %00111100
.byte %00011000

.byte %00011000
.byte %00111100
.byte %01111110
.byte %11111111
.byte %11111111
.byte %01111110
.byte %00111100
.byte %00011000

.res $2000 - 16