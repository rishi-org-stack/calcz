const std = @import("std");

//-------------------------
const lexemeF = @import("lexeme.zig");
const Lexeme = lexemeF.Lexeme;
const LexemeTypeTag = lexemeF.LexemeTypeTag;
//-------------------------

const SyntaxError = error{ErrIvalidSyntax};

pub fn syntaxAnalyzer(lexemes: []Lexeme, size: usize) !void {
    if (size == 0) return SyntaxError.ErrIvalidSyntax;

    const startLexeme: Lexeme = lexemes[0];
    if (startLexeme.kind == LexemeTypeTag.operator) return SyntaxError.ErrIvalidSyntax;

    const lastLexeme: Lexeme = lexemes[size - 1];
    if (lastLexeme.kind == LexemeTypeTag.operator) return SyntaxError.ErrIvalidSyntax;

    var iter: usize = 1;
    while (iter < size) {
        const prevIter: usize = iter - 1;

        const currentLexeme: Lexeme = lexemes[iter];
        const prevLexeme: Lexeme = lexemes[prevIter];

        if (currentLexeme.kind == prevLexeme.kind)
            return SyntaxError.ErrIvalidSyntax;

        iter += 1;
    }
}
