.segment "HEADER"
.byte "N", "E", "S", $1A
.byte $02        ; 2 x 16KB PRG-ROM = 32KB
.byte $01        ; 1 x 8KB CHR-ROM = 8KB
.byte $00        ; mapper 0, horizontal mirroring
.byte $00
.byte $00, $00, $00, $00, $00, $00, $00, $00

.segment "CODE"

.proc Reset
    sei
    cld

    ldx #$40
    stx $4017

    ldx #$FF
    txs

    inx
    stx $2000
    stx $2001
    stx $4010

Forever:
    jmp Forever
.endproc

.proc NMI
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
.res $2000