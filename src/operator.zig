const token = @import("token.zig");
const Token = token.Token;
const TokenType = token.TokenType;

pub const OperatorTag = enum { add, sub, div, mul };

pub const OperatorError = error{ ErrInvalidOperation, ErrInvalidToken };

pub const Operator = struct {
    kind: OperatorTag,

    pub fn fromToken(tk: Token) !Operator {
        var operator: Operator = undefined;

        switch (tk.kind) {
            TokenType.plus => {
                operator = Operator{ .kind = OperatorTag.add };
            },

            TokenType.minus => {
                operator = Operator{ .kind = OperatorTag.sub };
            },

            TokenType.multiply => {
                operator = Operator{ .kind = OperatorTag.mul };
            },

            TokenType.division => {
                operator = Operator{ .kind = OperatorTag.div };
            },

            else => {
                return OperatorError.ErrInvalidToken;
            },
        }

        return operator;
    }
};
