const token = @import("token.zig");
const Token = token.Token;
const TokenTypeTag = token.TokenTypeTag;

pub const OperatorTag = enum { add, sub, div, mul };

pub const OperatorError = error{ ErrInvalidOperation, ErrInvalidToken };

pub const Operator = struct {
    kind: OperatorTag,

    pub fn fromToken(tk: Token) !Operator {
        var operator: Operator = undefined;

        switch (tk.kind) {
            TokenTypeTag.plus => {
                operator = Operator{ .kind = OperatorTag.add };
            },

            TokenTypeTag.minus => {
                operator = Operator{ .kind = OperatorTag.sub };
            },

            TokenTypeTag.multiply => {
                operator = Operator{ .kind = OperatorTag.mul };
            },

            TokenTypeTag.division => {
                operator = Operator{ .kind = OperatorTag.div };
            },

            else => {
                return OperatorError.ErrInvalidToken;
            },
        }

        return operator;
    }
};
