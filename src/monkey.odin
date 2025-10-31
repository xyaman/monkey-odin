package src

import "core:fmt"
import "core:unicode/utf8"
import "core:testing"

Lexer :: struct {
    input: string,
    position: int,
    read_position: int,
    ch: rune,
    w: int,
}

Token :: struct {
    literal: string,
    type: TokenType,
}

TokenType :: enum {
    ILLEGAL,
    EOF,

    // identifiers + literals
    IDENT,
    INT,

    // operators
    ASSIGN,
    PLUS,

    // delimeters
    COMMA,
    SEMICOLON,

    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,

    // keywords
    FUNCTION,
    LET,
}

new_lexer :: proc (input: string) -> Lexer {
    l := Lexer{input = input}
    lexer_read_char(&l)
    return l
}


lexer_read_char :: proc (l: ^Lexer) {
    if l.read_position >= len(l.input) {
        l.ch = 0
        l.w = 1
    } else {
        l.ch, l.w = utf8.decode_rune_in_string(l.input[l.read_position:])
        l.position = l.read_position
        l.read_position += l.w
    }
}


lexer_next_token :: proc (l: ^Lexer) -> Token {
    token: Token;
    switch l.ch {
        case '=':
            token = {"=", .ASSIGN}
        case '+':
            token = {"+", .PLUS}
        case '(':
            token = {"(", .LPAREN}
        case ')':
            token = {")", .RPAREN}
        case '{':
            token = {"{", .LBRACE}
        case '}':
            token = {"}", .RBRACE}
        case ',':
            token = {",", .COMMA}
        case ';':
            token = {";", .SEMICOLON}
        case 0:
            token = {"", .EOF}
        case:
            fmt.println(l)
            token = {"", .ILLEGAL}
    }

    lexer_read_char(l)
    return token
}

@(test)
test_next_token :: proc(t: ^testing.T) {
    input := "=+(){},;"
    tests := []Token{
        { literal = "=", type = .ASSIGN },
        { literal = "+", type = .PLUS },
        { literal = "(", type =.LPAREN },
        { literal = ")", type =.RPAREN },
        { literal = "{", type =.LBRACE },
        { literal = "}", type =.RBRACE },
        { literal = ",", type =.COMMA },
        { literal = ";", type =.SEMICOLON },
        { literal = "", type = .EOF },
    }

    lexer := new_lexer(input)
    for it in tests {
        token := lexer_next_token(&lexer)
        testing.expectf(t, token.type == it.type, "Expected: %s, Got: %s", it.type, token.type)
    }
}
