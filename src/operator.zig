const token = @import("token.zig");
const Token = token.Token;
const TokenType = token.TokenType;

pub const OperatorTag = enum { add, sub, div, mul };

pub const OperationError = error{ ErrInvalidOperation, ErrInvalidToken };

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
                return OperationError.ErrInvalidToken;
            },
        }

        return operator;
    }
    // fn operate(self: Operator, operand1: Number, operand2: Number) !Number {
    //     if (operand1.kind != operand2.kind) return OperationError.ErrInvalidOperation;
    //     var result = Number{
    //         .kind = operand1.kind,
    //         .value = operand1.value,
    //     };

    //     switch (self.kind) {
    //         OperatorTag.add => {
    //             switch (result.kind) {
    //                 NumberTag.uint => {
    //                     result.value = NumberType{
    //                         .uint = result.value.uint + operand2.value.uint,
    //                     };
    //                 },

    //                 NumberTag.dounble => {
    //                     result.value = NumberType{
    //                         .double = result.value.double + operand2.value.double,
    //                     };
    //                 },
    //             }
    //         },

    //         OperatorTag.sub => {
    //             switch (result.kind) {
    //                 NumberTag.uint => {
    //                     result.value = NumberType{
    //                         .uint = result.value.uint - operand2.value.uint,
    //                     };
    //                 },

    //                 NumberTag.double => {
    //                     result.value = NumberType{
    //                         .double = result.value.double - operand2.value.double,
    //                     };
    //                 },
    //             }
    //         },

    //         OperatorTag.div => {
    //             switch (result.kind) {
    //                 NumberTag.uint => {
    //                     result.value = NumberType{
    //                         .uint = result.value.uint / operand2.value.uint,
    //                     };
    //                 },

    //                 NumberTag.double => {
    //                     result.value = NumberType{
    //                         .double = result.value.double / operand2.value.double,
    //                     };
    //                 },
    //             }
    //         },

    //         OperatorTag.mul => {
    //             switch (result.kind) {
    //                 NumberTag.uint => {
    //                     result.value = NumberType{
    //                         .uint = result.value.uint * operand2.value.uint,
    //                     };
    //                 },

    //                 NumberTag.double => {
    //                     result.value = NumberType{
    //                         .double = result.value.double * operand2.value.double,
    //                     };
    //                 },
    //             }
    //         },
    //     }
    // }
};
