pub const TokenType = enum {
    plus,
    minus,
    division,
    multiply,
    operator,
    digit,
    dot,
    space,
    none,

    pub fn fromByte(identifier: u8) TokenType {
        switch (identifier) {
            42 => return TokenType.multiply,
            43 => return TokenType.plus,
            45 => return TokenType.minus,
            47 => return TokenType.division,
            48...58 => return TokenType.digit,
            46 => return TokenType.dot,
            32 => return TokenType.space,
            else => return TokenType.none,
        }
    }
};

pub const TokenError = error{ErrInvalidToken};

pub const Token = struct {
    kind: TokenType,
    value: u8,

    pub fn fromByte(idetifier: u8) !Token {
        var tokenType: TokenType = TokenType.fromByte(idetifier);

        if (tokenType == TokenType.none) return TokenError.ErrInvalidToken;

        return Token{
            .kind = tokenType,
            .value = idetifier,
        };
    }
};
