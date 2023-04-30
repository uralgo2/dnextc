module lexer.token;

import std.conv;
import std.traits : isIntegral, isSomeString, isSomeChar, isFloatingPoint;
import std.string : startsWith, replace;

const isLikeInteger(T) = isIntegral!T;
const isLikeChar(T) = isSomeChar!T;
const isLikeString(T) = isSomeString!T;
const isLikeFloating(T) = isFloatingPoint!T;

struct TokenPosition {
    int line, symbol;
    string source;
}

enum TokenType {
    Invalid,
    Identifier,
    Char,
    String,
    Integer,
    Float,
    Special,
    Operator,
    EndOfFile
}

struct Token {
    private TokenPosition m_position;
    private TokenType m_type;
    private string m_value;

    public this(TokenPosition position, TokenType type, string value) {
        this.m_position = position;
        this.m_type = type;
        this.m_value = value;
    }

    public bool isToken(TokenType type) {
        return this.m_type == type;
    }

    public TokenPosition position() {
        return this.m_position;
    }

    public TokenType type() {
        return this.m_type;
    }

    public T value(T)() {
        static if (isLikeInteger!T) {
            auto value = this.m_value;
            auto radix = 10;

            if (value.startsWith("0x")) {
                radix = 16;
                value = value.replace(0, 2, "");
            }
            else if (value.startsWith("0o")) {
                radix = 8;
                value = value.replace(0, 2, "");
            }
            else if (value.startsWith("0b")) {
                radix = 2;
                value = value.replace(0, 2, "");
            }
            else if (value.startsWith("0d")) {
                radix = 10;
                value = value.replace(0, 2, "");
            }
            else if (value.startsWith("0t")) {
                radix = 3;
                value = value.replace(0, 2, "");
            }

            assert(this.m_type == TokenType.Integer, "The token type must be integer!");

            return value.to!T(radix);
        }
        else static if (isLikeFloating!T) {
            assert(this.m_type == TokenType.Float, "The token type must be float!");

            return this.m_value.to!T;
        }
        else static if (isLikeChar!T) {
            assert(this.m_type == TokenType.Char
                    || this.m_type == TokenType.Special,
                    "The token type must be char or special!");

            return this.m_value.to!T;
        }
        else static if (isLikeString!T) {
            assert(this.m_type == TokenType.String
                    || this.m_type == TokenType.Identifier
                    || this.m_type == TokenType.Special
                    || this.m_type == TokenType.Operator,
                    "The token type must be string, id, special or operator!");

            return this.m_value.to!T;
        }

        assert(false, "Gave not supported type!");
    }
}
