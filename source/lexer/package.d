module lexer;

import std.ascii;
import std.conv;
import std.stdio;
import std.algorithm : canFind, startsWith;

public import lexer.token;

private bool hasStartsWith(string[] array, string prefix) {
    foreach (elem; array) {
        if (elem.startsWith(prefix))
            return true;
    }

    return false;
}

private string unescape(string s) {
    import std.format : FormatSpec, unformatValue;

    FormatSpec!char f;
    string str = `["` ~ s ~ `"]`;
    return unformatValue!(string[])(str, f)[0];
}

struct LexerState {
    int line, symbol, absolute;
    string source;
    char currentChar;
}

class Lexer {
    private LexerState m_state;
    private string m_data;
    private string[] m_specials, m_operators;

    public this(string src, string[] operators, string[] specials, string srcName = "input") {
        this.m_state = LexerState(0, 0, 0, srcName, '\0');
        this.m_data = src;
        this.m_operators = operators;
        this.m_specials = specials;
    }

    public LexerState state() {
        return this.m_state;
    }

    public void state(LexerState state) {
        this.m_state = state;
    }

    private void skipWhiteSpaces() {
        auto chr = this.peekChar;

        while (chr == ' ' || chr == '\t' || chr == '\r' || chr == '\n') {
            this.nextChar();
            chr = this.peekChar;
        }
    }

    private char peekChar() {
        return this.m_state.absolute >= this.m_data.length
            ? '\0' : this.m_data[this.m_state.absolute];
    }

    private char nextChar() {
        auto chr = this.m_state.currentChar =
            this.m_state.absolute >= this.m_data.length
            ? '\0' : this.m_data[this.m_state.absolute++];

        ++this.m_state.symbol;

        if (chr == '\n') {
            ++this.m_state.line;
            this.m_state.symbol = 0;
        }

        return chr;
    }

    private Token id() {
        auto pos = this.currentTokenPosition;
        string raw = "";
        char chr = this.peekChar;

        while (isAlpha(chr) || chr == '_' || isDigit(chr)) {
            raw ~= chr;

            this.nextChar();

            chr = this.peekChar;
        }

        return Token(
            pos,
            TokenType.Identifier,
            raw);
    }

    private Token number() {
        auto pos = this.currentTokenPosition;
        string raw = "";
        char chr = this.peekChar;
        bool isFloat = false, isRadixSpecified = false;

        while (isDigit(chr)
            || (!isFloat && chr == '.')
            || (!isRadixSpecified && chr != 'e' && isAlpha(chr))
            || (isRadixSpecified && chr != 'e' && isAlpha(chr))
            || (isFloat && chr == 'e')) {
            if (chr == '.')
                isFloat = true;
            else if (!isRadixSpecified && chr != 'e' && isAlpha(chr))
                isRadixSpecified = true;
            
            raw ~= chr;

            this.nextChar();

            chr = this.peekChar;
        }

        return Token(
            pos,
            isFloat ? TokenType.Float : TokenType.Integer,
            raw);
    }

    private Token _string() {
        auto pos = this.currentTokenPosition;
        string raw = "";

        this.nextChar(); // skip quote

        char chr = this.peekChar;

        while (chr != '\"' && chr != '\0') {
            raw ~= chr;

            this.nextChar();

            if (chr == '\\') {
                raw ~= this.peekChar;

                this.nextChar();
            }
            chr = this.peekChar;
        }

        assert(chr == '\"', "Expected quote.");

        this.nextChar(); // skip quote

        return Token(
            pos,
            TokenType.String,
            unescape(raw));
    }

    private Token chr() {
        return Token(
            TokenPosition(this.m_state.line, this.m_state.symbol, this.m_state.source),
            TokenType.Invalid,
            this.nextChar.to!string);
    }

    private Token specialOrOperatorOrInvalid() {
        auto pos = this.currentTokenPosition;
        string raw = "";

        char chr = this.peekChar;

        do {
            raw ~= chr;

            this.nextChar();

            chr = this.peekChar;
        }
        while (this.m_operators.hasStartsWith(raw ~ chr)
            || this.m_specials.hasStartsWith(raw ~ chr));

        if (this.m_operators.canFind(raw)) {
            return Token(
                pos,
                TokenType.Operator,
                raw);
        }

        if (this.m_specials.canFind(raw)) {
            return Token(
                pos,
                TokenType.Special,
                raw);
        }

        return Token(
            pos,
            TokenType.Invalid,
            raw);
    }

    private Token invalid() {
        return Token(
            TokenPosition(this.m_state.line, this.m_state.symbol, this.m_state.source),
            TokenType.Invalid,
            this.nextChar.to!string);
    }

    private Token eof() {
        return Token(
            TokenPosition(this.m_state.line, this.m_state.symbol, this.m_state.source),
            TokenType.EndOfFile,
            this.nextChar.to!string);
    }

    public Token nextToken() {
        this.skipWhiteSpaces();

        char chr = this.peekChar;

        if (chr == '\0') {
            return this.eof();
        }
        else if (isAlpha(chr) || chr == '_') {
            return this.id();
        }
        else if (isDigit(chr)) {
            return this.number();
        }
        else if (chr == '\"') {
            return this._string();
        }
        else if (chr == '\'') {
            return this.chr();
        }
        else {
            return this.specialOrOperatorOrInvalid();
        }
    }

    public TokenPosition currentTokenPosition() {
        return TokenPosition(this.m_state.line, this.m_state.symbol, this.m_state.source);
    }
}
