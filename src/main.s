.segment "HEADER"
    .byte "N", "E", "S", $1A
    .byte $02
    .byte $01
    .byte $00
    .byte $00
    .byte $00, $00, $00, $00, $00, $00, $00, $00

.segment "ZEROPAGE"
frame_ready:  .res 1
buttons:      .res 1
bullet_active:.res 1
bullet_x:     .res 1
bullet_y:     .res 1
enemy_active: .res 1
enemy_x:      .res 1
enemy_y:      .res 1
lives:        .res 1
player_hit:   .res 1
hit_cooldown: .res 1

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
    sta buttons
    sta bullet_active
    sta bullet_x
    sta bullet_y
    sta enemy_active
    sta enemy_x
    sta enemy_y
    sta player_hit
    sta hit_cooldown

    lda #$03
    sta lives

    lda #$01
    sta enemy_active
    lda #80
    sta enemy_x
    lda #24
    sta enemy_y

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

    lda #24
    sta $0208
    lda #$02
    sta $0209
    lda #$00
    sta $020A
    lda #80
    sta $020B

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

    lda lives
    beq MainLoop

    lda hit_cooldown
    beq CheckLeft
    dec hit_cooldown

CheckLeft:
    lda buttons
    and #%00000010
    beq CheckRight

    lda $0203
    cmp #8
    beq CheckRight
    sec
    sbc #1
    sta $0203

CheckRight:
    lda buttons
    and #%00000001
    beq CheckFire

    lda $0203
    cmp #240
    beq CheckFire
    clc
    adc #1
    sta $0203

CheckFire:
    lda buttons
    and #%10000000
    beq UpdateBullet

    lda bullet_active
    bne UpdateBullet

    lda #$01
    sta bullet_active
    lda $0203
    sta bullet_x
    lda $0200
    sta bullet_y

UpdateBullet:
    lda bullet_active
    beq HideBullet

    lda bullet_y
    sec
    sbc #2
    sta bullet_y
    cmp #8
    bcs DrawBullet

    lda #$00
    sta bullet_active
    jmp HideBullet

DrawBullet:
    sta $0204
    lda #$01
    sta $0205
    lda #$00
    sta $0206
    lda bullet_x
    sta $0207
    jmp UpdateEnemy

HideBullet:
    lda #$FE
    sta $0204

UpdateEnemy:
    lda enemy_active
    bne EnemyActive
    jmp HideEnemy

EnemyActive:
    lda enemy_y
    clc
    adc #1
    sta enemy_y
    cmp #232
    bcc CheckCollision

    lda #24
    sta enemy_y
    lda #80
    sta enemy_x

CheckCollision:
    lda bullet_active
    beq CheckPlayerCollision
    lda enemy_active
    beq CheckPlayerCollision

    lda bullet_x
    clc
    adc #7
    cmp enemy_x
    bcc CheckPlayerCollision

    lda enemy_x
    clc
    adc #7
    cmp bullet_x
    bcc CheckPlayerCollision

    lda bullet_y
    clc
    adc #7
    cmp enemy_y
    bcc CheckPlayerCollision

    lda enemy_y
    clc
    adc #7
    cmp bullet_y
    bcc CheckPlayerCollision

    lda #$00
    sta bullet_active
    lda #$FE
    sta $0204

    lda #24
    sta enemy_y
    lda #80
    sta enemy_x

CheckPlayerCollision:
    lda hit_cooldown
    bne NoPlayerCollision

    lda enemy_active
    beq NoPlayerCollision

    lda $0203
    clc
    adc #7
    cmp enemy_x
    bcc NoPlayerCollision

    lda enemy_x
    clc
    adc #7
    cmp $0203
    bcc NoPlayerCollision

    lda $0200
    clc
    adc #7
    cmp enemy_y
    bcc NoPlayerCollision

    lda enemy_y
    clc
    adc #7
    cmp $0200
    bcc NoPlayerCollision

    lda #$01
    sta player_hit

NoPlayerCollision:
HandlePlayerHit:
    lda player_hit
    beq NoHitReset

    lda lives
    beq FinishHitReset
    sec
    sbc #1
    sta lives

FinishHitReset:
    lda #$00
    sta bullet_active
    sta player_hit
    lda #$FE
    sta $0204

    lda #120
    sta $0200
    sta bullet_y
    lda #120
    sta $0203
    sta bullet_x

    lda #24
    sta enemy_y
    lda #80
    sta enemy_x
    lda #$01
    sta enemy_active

    lda #60
    sta hit_cooldown

NoHitReset:

DrawEnemy:
    lda enemy_active
    beq HideEnemy

    lda enemy_y
    sta $0208
    lda #$02
    sta $0209
    lda #$00
    sta $020A
    lda enemy_x
    sta $020B
    jmp MainLoop

HideEnemy:
    lda #$FE
    sta $0208
    jmp MainLoop
.endproc

.proc ReadController1
    lda #$01
    sta $4016
    lda #$00
    sta $4016

    lda #$00
    sta buttons

    ldx #$08
ReadButtonsLoop:
    lda $4016
    and #$01
    lsr a
    rol buttons
    dex
    bne ReadButtonsLoop
    rts
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
    jsr ReadController1

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
    .byte $21, $0F, $0F, $0F
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

    .byte %10000001
    .byte %01000010
    .byte %00100100
    .byte %00011000
    .byte %00011000
    .byte %00100100
    .byte %01000010
    .byte %10000001
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
    .byte %00111100
    .byte %00011000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000
    .byte %00000000

    .res $2000 - 64