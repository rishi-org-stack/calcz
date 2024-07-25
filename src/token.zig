pub const TokenTypeTag = enum {
    plus,
    minus,
    division,
    multiply,
    operator,
    digit,
    dot,
    space,
    none,

    pub fn fromByte(identifier: u8) TokenTypeTag {
        switch (identifier) {
            42 => return TokenTypeTag.multiply,
            43 => return TokenTypeTag.plus,
            45 => return TokenTypeTag.minus,
            47 => return TokenTypeTag.division,
            48...58 => return TokenTypeTag.digit,
            46 => return TokenTypeTag.dot,
            32 => return TokenTypeTag.space,
            else => return TokenTypeTag.none,
        }
    }
};

pub const TokenError = error{ErrInvalidToken};

pub const Token = struct {
    kind: TokenTypeTag,
    value: u8,

    pub fn fromByte(idetifier: u8) !Token {
        var tokenTypeTag: TokenTypeTag = TokenTypeTag.fromByte(idetifier);

        if (tokenTypeTag == TokenTypeTag.none) return TokenError.ErrInvalidToken;

        return Token{
            .kind = tokenTypeTag,
            .value = idetifier,
        };
    }
};
