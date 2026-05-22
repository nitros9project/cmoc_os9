* Shared assembler-side ctype character-class constants.

_CONTROL           equ       $01       ; control-character class bit
_UPPER             equ       $02       ; uppercase alphabetic class bit
_LOWER             equ       $04       ; lowercase alphabetic class bit
_DIGIT             equ       $08       ; decimal digit class bit
_WHITE             equ       $10       ; whitespace class bit
_PUNCT             equ       $20       ; punctuation/printable-symbol class bit
_HEXDIG            equ       $40       ; hexadecimal digit class bit
