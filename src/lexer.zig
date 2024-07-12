//-------------------------
const tokenF = @import("token.zig");
const Token = tokenF.Token;
const TokenType = tokenF.TokenType;
const TokenError = tokenF.TokenError;
//-------------------------

//-------------------------
const lexemeF = @import("lexeme.zig");
const Lexeme = lexemeF.Lexeme;
const LexemeTypeTag = lexemeF.LexemeTypeTag;
//-------------------------

pub const LexicalError = error{
    ErrUnknownToken,
};

pub const Lexer = struct {
    pub fn fromBufferStream(buffer: []const u8, size: usize) ![]Lexeme {
        var i: usize = 0;
        var lexmes: [size]Lexeme = undefined;

        var newsize: usize = 0;
        while (i < size) {
            var currentByte: u8 = buffer[i];
            var currentToken: Token = Token.fromByte(currentByte) catch |err| switch (err) {
                TokenError.ErrInvalidToken => return LexicalError.ErrUnknownToken,
            };
            var lexeme: Lexeme = try Lexeme.new(currentToken);

            var j: usize = i + 1;
            while (j < size) {
                var forwardByte: u8 = buffer[j];
                // std.debug.print("j {d} forwardByte {d}\n", .{ j, forwardByte });
                var forwardToken: Token = Token.fromByte(forwardByte) catch |err| switch (err) {
                    TokenError.ErrInvalidToken => return LexicalError.ErrUnknownToken,
                };
                try lexeme.fromToken(forwardToken);

                if (forwardToken.kind == TokenType.space) {
                    j += 1;
                    break;
                }
                j += 1;
            }

            i = j;
            lexmes[newsize] = lexeme;
            newsize += 1;
        }
    }
};
