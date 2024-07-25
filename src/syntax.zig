const std = @import("std");

//-------------------------
const lexemeF = @import("lexeme.zig");
const Lexeme = lexemeF.Lexeme;
const LexemeTypeTag = lexemeF.LexemeTypeTag;
//-------------------------

const SyntaxError = error{ErrInvalidSyntax};

pub fn syntaxAnalyzer(lexemes: []Lexeme, size: usize) !void {
    if (size == 0) return SyntaxError.ErrInvalidSyntax;

    const startLexeme: Lexeme = lexemes[0];
    if (startLexeme.kind == LexemeTypeTag.operator) return SyntaxError.ErrInvalidSyntax;

    const lastLexeme: Lexeme = lexemes[size - 1];
    if (lastLexeme.kind == LexemeTypeTag.operator) return SyntaxError.ErrInvalidSyntax;

    var iter: usize = 1;
    while (iter < size) {
        const prevIter: usize = iter - 1;

        const currentLexeme: Lexeme = lexemes[iter];
        const prevLexeme: Lexeme = lexemes[prevIter];

        if (currentLexeme.kind == prevLexeme.kind)
            return SyntaxError.ErrInvalidSyntax;

        iter += 1;
    }
}
