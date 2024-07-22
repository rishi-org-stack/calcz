const std = @import("std");
//-------------------------
const tokenF = @import("token.zig");
const Token = tokenF.Token;
const TokenType = tokenF.TokenType;
const TokenError = tokenF.TokenError;
//-------------------------

//-------------------------
const operatorF = @import("operator.zig");
const Operator = operatorF.Operator;
const OperatorTag = operatorF.OperatorTag;
const OperatorError = operatorF.OperationError;
//------------------------

//-------------------------
const numberF = @import("number.zig");
const Number = numberF.Number;
//-------------------------

pub const LexemeType = union { number: Number, operator: Operator };
pub const LexemeTypeTag = enum { number, operator };
pub const LexemeError = error{ErrInvalidLexeme};

pub const Lexeme = struct {
    value: LexemeType,
    kind: LexemeTypeTag,

    pub fn new(tk: Token) !Lexeme {
        var lexeme: Lexeme = undefined;
        switch (tk.kind) {
            TokenType.digit => {
                lexeme = Lexeme{ .kind = LexemeTypeTag.number, .value = LexemeType{ .number = Number{ .value = tk.value - 48, .exponent = 0, .dotFound = false } } };
            },

            else => {
                var operator = try Operator.fromToken(tk);
                lexeme = Lexeme{ .kind = LexemeTypeTag.operator, .value = LexemeType{ .operator = operator } };
            },
        }
        return lexeme;
    }

    pub fn fromToken(self: *Lexeme, tk: Token) !void {
        switch (tk.kind) {
            TokenType.digit => {
                var last: u128 = self.value.number.value;
                self.value.number.value = last * 10 + (tk.value - 48);
                if (self.value.number.dotFound) self.value.number.exponent += 1;
            },
            TokenType.dot => {
                // var last: u128 = self.value.number.exponent;
                if (self.value.number.dotFound) return LexemeError.ErrInvalidLexeme;
                self.value.number.dotFound = true;
            },
            else => {},
        }
    }

    pub fn log(self: Lexeme) void {
        if (self.kind == LexemeTypeTag.number) {
            std.debug.print("value {any}\n", .{self.value.number.value});
            std.debug.print("exponent {any}\n", .{self.value.number.exponent});
        }
        if (self.kind == LexemeTypeTag.operator) {
            std.debug.print("{any}\n", .{self.value.operator.kind});
        }
    }
};

pub fn operate(operatorLexeme: Lexeme, param1: Lexeme, param: Lexeme) Lexeme {
    if (param.kind != LexemeTypeTag.number or param1.kind != LexemeTypeTag.number) {
        std.debug.print("add operation not possible\n", .{});
    }

    // return Lexeme{ .kind = LexemeTypeTag.number, .value = LexemeType{ .number = Number{
    //     .dotFound = param.value.number.dotFound,
    //     .exponent = param.value.number.exponent,
    //     .value = param1.value.number.value + param.value.number.value,
    // } } };

    var res: Lexeme = undefined;
    if (operatorLexeme.kind != LexemeTypeTag.operator) {
        std.debug.print("we need operator lexeme\n", .{});
    }

    switch (operatorLexeme.value.operator.kind) {
        OperatorTag.add => {
            res = Lexeme{ .kind = LexemeTypeTag.number, .value = LexemeType{ .number = Number{
                .dotFound = param.value.number.dotFound,
                .exponent = param.value.number.exponent,
                .value = param1.value.number.value + param.value.number.value,
            } } };
        },
        OperatorTag.sub => {
            res = Lexeme{ .kind = LexemeTypeTag.number, .value = LexemeType{ .number = Number{
                .dotFound = param.value.number.dotFound,
                .exponent = param.value.number.exponent,
                .value = param1.value.number.value - param.value.number.value,
            } } };
        },
        OperatorTag.mul => {
            res = Lexeme{ .kind = LexemeTypeTag.number, .value = LexemeType{ .number = Number{
                .dotFound = param.value.number.dotFound,
                .exponent = param.value.number.exponent,
                .value = param1.value.number.value * param.value.number.value,
            } } };
        },
        OperatorTag.div => {
            res = Lexeme{ .kind = LexemeTypeTag.number, .value = LexemeType{ .number = Number{
                .dotFound = param.value.number.dotFound,
                .exponent = param.value.number.exponent,
                .value = param1.value.number.value / param.value.number.value,
            } } };
        },
    }

    return res;
}
