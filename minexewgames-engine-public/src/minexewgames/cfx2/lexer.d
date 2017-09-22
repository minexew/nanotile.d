/*
    Boost Software License - Version 1.0 - August 17th, 2003
    
    Permission is hereby granted, free of charge, to any person or organization
    obtaining a copy of the software and accompanying documentation covered by
    this license (the "Software") to use, reproduce, display, distribute,
    execute, and transmit the Software, and to prepare derivative works of the
    Software, and to permit third-parties to whom the Software is furnished to
    do so, all subject to the following:
    
    The copyright notices in the Software and this entire statement, including
    the above license grant, this restriction and the following disclaimer,
    must be included in all copies of the Software, in whole or in part, and
    all derivative works of the Software, unless such copies or derivative
    works are solely in the form of machine-executable object code generated by
    a source language processor.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
    SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
    FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
*/

module minexewgames.cfx2.lexer;

import minexewgames.framework.stream;

import core.stdc.ctype;
import std.conv;

bool isIdentChar(char c) {
    return isalnum(c) || (c) == '_' || (c) == '-' || (c) == '~' || (c) == '!'
            || (c) == '@' || (c) == '#' || (c) == '$' || (c) == '%';
}

enum TokenType {
    text,
    colon,
    lparen,
    rparen,
    comma,
}

struct Token {
    TokenType type;
    string text;

    int line;
    uint indent;
}

class Lexer {
    this(InputStream input, string fileName) {
        this.fileName = fileName;
        this.line = 1;
        
        this.input = input;
        this.queuedChar = 0;
        
        this.currentTokenValid = false;
    }
    
    void error(string msg) {
        throw new Exception(fileName ~ " " ~ to!string(line) ~ ": " ~ msg);
    }
    
    int getCurrent(out Token token_out) {
        char resolutor;
        int indent;

        if (currentTokenValid) {
            token_out = currentToken;
            return true;
        }

        /* Skip all spaces, newlines, tabs etc. */
        label_skip_spaces:
    
        indent = 0;
    
        do {
            if (queuedChar) {
                resolutor = queuedChar;
                queuedChar = 0;
            }
            else if (!readChar(resolutor))
                return false;
    
            if (resolutor == '\n') {
                line++;
                indent = 0;
            }
            else if (resolutor == ' ')
                indent++;
            else if (resolutor == '\t')
                indent += 4;
        }
        while (isspace(resolutor));
    
        /* A multi-line comment was found */
        if (resolutor == '{') {
            /* just look for '}' and don't forget to count lines */
            do {
                if (!readChar(resolutor))
                    return false;
    
                if (resolutor == '\n')
                    line++;
            }
            while (resolutor != '}');
    
            /* ...and go back to the start */
            goto label_skip_spaces;
        }

        // FIXME FIXME
        //Token token = currentToken;
        alias token = currentToken;
    
        /* default result */
        token.indent = indent;
        token.line = line;
    
        /* Find out which token is it. */
        switch (resolutor) {
            //case '*': token.type = T_asterisk; break;
            case ':': token.type = TokenType.colon; break;
            case ',': token.type = TokenType.comma; break;
            //case '=': token.type = T_equals; break;
            case '(': token.type = TokenType.lparen; break;
            case ')': token.type = TokenType.rparen; break;
    
            default:
                /* Identifier */
                if (isIdentChar(resolutor)) {
                    if (!readIdent(resolutor))
                        return false;
    
                    token.type = TokenType.text;
                }
                /* Text value */
                else if (resolutor == '\'') {
                    if (!readString('\''))
                        return false;
    
                    token.type = TokenType.text;
                }
                else {
                    error("Unexpected character in input.");
                }
        }
    
        token_out = currentToken;
        currentTokenValid = true;
        return true;
    }

    bool readIdent(char nextChar) {
        currentToken.text = "";
        
        /* Continue until an non-ident character is met */
        while (isIdentChar(nextChar)) {
            // TODO: optimize
            currentToken.text = currentToken.text ~ nextChar;
    
            /* Read next char from the input */
            if (!readChar(nextChar)) {
                nextChar = 0;
                break;
            }
        }

        queuedChar = nextChar;
        return true;
    }
    
    bool readString(char terminating) {
        // FIXME: Throw an exception on EOF
        
        char nextChar;
        currentToken.text = "";

        for ( ; ; ) {
            if (!readChar(nextChar))
                return false;
    
            if (nextChar == terminating)
                break;
        
            if (nextChar == '\\')
                if (!readChar(nextChar))
                    return false;
    
            // TODO: optimize
            currentToken.text = currentToken.text ~ nextChar;
        }
        
        return true;
    }
    
    bool readToken(out Token token) {
        if (!currentTokenValid)
            if (!getCurrent(token))
                return false;
                
        currentTokenValid = false;
        return true;
    }
    
    private bool readChar(out char value) {
        if (input.readBytes(cast(ubyte*) &value, 1) == 1)
            return true;
        else
            return false;
    }
    
    string fileName;
    uint line;
    
    InputStream input;
    char queuedChar;
    
    Token currentToken;
    bool currentTokenValid;
}
