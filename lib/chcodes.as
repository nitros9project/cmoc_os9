                    section   rodata    ; begin rodata section

__chcodes           EXPORT              ; export this symbol
_chcodes            EXPORT              ; export this symbol

* Initialized Data (class G)
* Each entry is a character-class flag byte indexed by the character code.
* The trailing columns document decimal value, hex value, bit pattern, mnemonic,
* and a human-readable description for the matching entry.
__chcodes:
_chcodes:
                    fcb       $01       ; 0 00 00000000 NUL null
                    fcb       $01       ; 1 01 00000001 SOH start of header
                    fcb       $01       ; 2 02 00000010 STX start of text
                    fcb       $01       ; 3 03 00000011 ETX end of text
                    fcb       $01       ; 4 04 00000100 EOT end of transmission
                    fcb       $01       ; 5 05 00000101 ENQ enquiry
                    fcb       $01       ; 6 06 00000110 ACK acknowledge
                    fcb       $01       ; 7 07 00000111 BEL bell
                    fcb       $01       ; 8 08 00001000 BS backspace
                    fcb       $11       ; 9 09 00001001 HT horizontal tab
                    fcb       $11       ; 10 0A 00001010 LF line feed
                    fcb       $11       ; 11 0B 00001011 VT vertical tab
                    fcb       $11       ; 12 0C 00001100 FF form feed
                    fcb       $11       ; 13 0D 00001101 CR enter / carriage return
                    fcb       $01       ; 14 0E 00001110 SO shift out
                    fcb       $01       ; 15 0F 00001111 SI shift in
                    fcb       $01       ; 16 10 00010000 DLE data link escape
                    fcb       $01       ; 17 11 00010001 DC1 device control 1
                    fcb       $01       ; 18 12 00010010 DC2 device control 2
                    fcb       $01       ; 19 13 00010011 DC3 device control 3
                    fcb       $01       ; 20 14 00010100 DC4 device control 4
                    fcb       $01       ; 21 15 00010101 NAK negative acknowledge
                    fcb       $01       ; 22 16 00010110 SYN synchronize
                    fcb       $01       ; 23 17 00010111 ETB end of trans. block
                    fcb       $01       ; 24 18 00011000 CAN cancel
                    fcb       $01       ; 25 19 00011001 EM end of medium
                    fcb       $01       ; 26 1A 00011010 SUB substitute
                    fcb       $01       ; 27 1B 00011011 ESC escape
                    fcb       $01       ; 28 1C 00011100 FS file separator
                    fcb       $01       ; 29 1D 00011101 GS group separator
                    fcb       $01       ; 30 1E 00011110 RS record separator
                    fcb       $01       ; 31 1F 00011111 US unit separator
                    fcb       $30       ; 32 20 00100000 SP space
                    fcb       $20       ; 33 21 00100001 ! exclamation mark
                    fcb       $20       ; 34 22 00100010 " double quote
                    fcb       $20       ; 35 23 00100011 # number
                    fcb       $20       ; 36 24 00100100 $ dollar
                    fcb       $20       ; 37 25 00100101 % percent
                    fcb       $20       ; 38 26 00100110 & ampersand
                    fcb       $20       ; 39 27 00100111 ' single quote
                    fcb       $20       ; 40 28 00101000 ( left parenthesis
                    fcb       $20       ; 41 29 00101001 ) right parenthesis
                    fcb       $20       ; asterisk
                    fcb       $20       ; 43 2B 00101011 + plus
                    fcb       $20       ; 44 2C 00101100 , comma
                    fcb       $20       ; 45 2D 00101101 - minus
                    fcb       $20       ; 46 2E 00101110 . period
                    fcb       $20       ; 47 2F 00101111 / slash
                    fcb       $48       ; 48 30 00110000 0 zero
                    fcb       $48       ; 49 31 00110001 1 one
                    fcb       $48       ; 50 32 00110010 2 two
                    fcb       $48       ; 51 33 00110011 3 three
                    fcb       $48       ; 52 34 00110100 4 four
                    fcb       $48       ; 53 35 00110101 5 five
                    fcb       $48       ; 54 36 00110110 6 six
                    fcb       $48       ; 55 37 00110111 7 seven
                    fcb       $48       ; 56 38 00111000 8 eight
                    fcb       $48       ; 57 39 00111001 9 nine
                    fcb       $20       ; 58 3A 00111010 : colon
                    fcb       $20       ; semicolon
                    fcb       $20       ; 60 3C 00111100 < less than
                    fcb       $20       ; 61 3D 00111101 = equality sign
                    fcb       $20       ; 62 3E 00111110 > greater than
                    fcb       $20       ; 63 3F 00111111 ? question mark
                    fcb       $20       ; 64 40 01000000 @ at sign
                    fcb       $42       ; 65 41 01000001 A
                    fcb       $42       ; 66 42 01000010 B
                    fcb       $42       ; 67 43 01000011 C
                    fcb       $42       ; 68 44 01000100 D
                    fcb       $42       ; 69 45 01000101 E
                    fcb       $42       ; 70 46 01000110 F
                    fcb       $02       ; 71 47 01000111 G
                    fcb       $02       ; 72 48 01001000 H
                    fcb       $02       ; 73 49 01001001 I
                    fcb       $02       ; 74 4A 01001010 J
                    fcb       $02       ; 75 4B 01001011 K
                    fcb       $02       ; 76 4C 01001100 L
                    fcb       $02       ; 77 4D 01001101 M
                    fcb       $02       ; 78 4E 01001110 N
                    fcb       $02       ; 79 4F 01001111 O
                    fcb       $02       ; 80 50 01010000 P
                    fcb       $02       ; 81 51 01010001 Q
                    fcb       $02       ; 82 52 01010010 R
                    fcb       $02       ; 83 53 01010011 S
                    fcb       $02       ; 84 54 01010100 T
                    fcb       $02       ; 85 55 01010101 U
                    fcb       $02       ; 86 56 01010110 V
                    fcb       $02       ; 87 57 01010111 W
                    fcb       $02       ; 88 58 01011000 X
                    fcb       $02       ; 89 59 01011001 Y
                    fcb       $02       ; 90 5A 01011010 Z
                    fcb       $20       ; 91 5B 01011011 [ left square bracket
                    fcb       $20       ; 92 5C 01011100 \ backslash
                    fcb       $20       ; 93 5D 01011101 ] right square bracket
                    fcb       $20       ; 94 5E 01011110 ^ caret / circumflex
                    fcb       $20       ; 95 5F 01011111 _ underscore
                    fcb       $20       ; 96 60 01100000 ` grave / accent
                    fcb       $44       ; 97 61 01100001 a
                    fcb       $44       ; 98 62 01100010 b
                    fcb       $44       ; 99 63 01100011 c
                    fcb       $44       ; 100 64 01100100 d
                    fcb       $44       ; 101 65 01100101 e
                    fcb       $44       ; 102 66 01100110 f
                    fcb       $04       ; 103 67 01100111 g
                    fcb       $04       ; 104 68 01101000 h
                    fcb       $04       ; 105 69 01101001 i
                    fcb       $04       ; 106 6A 01101010 j
                    fcb       $04       ; 107 6B 01101011 k
                    fcb       $04       ; 108 6C 01101100 l
                    fcb       $04       ; 109 6D 01101101 m
                    fcb       $04       ; 110 6E 01101110 n
                    fcb       $04       ; 111 6F 01101111 o
                    fcb       $04       ; 112 70 01110000 p
                    fcb       $04       ; 113 71 01110001 q
                    fcb       $04       ; 114 72 01110010 r
                    fcb       $04       ; 115 73 01110011 s
                    fcb       $04       ; 116 74 01110100 t
                    fcb       $04       ; 117 75 01110101 u
                    fcb       $04       ; 118 76 01110110 v
                    fcb       $04       ; 119 77 01110111 w
                    fcb       $04       ; 120 78 01111000 x
                    fcb       $04       ; 121 79 01111001 y
                    fcb       $04       ; 122 7A 01111010 z
                    fcb       $20       ; 123 7B 01111011 { left curly bracket
                    fcb       $20       ; 124 7C 01111100 | vertical bar
                    fcb       $20       ; 125 7D 01111101 } right curly bracket
                    fcb       $20       ; 126 7E 01111110 ~ tilde
                    fcb       $01       ; 127 7F 01111111 DEL delete

                    endsect             ; end current section
