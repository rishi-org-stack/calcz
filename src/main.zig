const std = @import("std");
const assert = std.debug.assert;

//-------------------------
const lexerF = @import("lexer.zig");
const Lexer = lexerF.Lexer;
const LexicalError = lexerF.LexicalError;
//-------------------------

const syntax = @import("syntax.zig");
const Allocator = std.mem.Allocator;
const gpa = std.heap.GeneralPurposeAllocator;
const Queue = std.atomic.Queue;

/// Node inside the tree.
pub const Node = struct {
    value: Lexeme,
    left: ?*Node,
    right: ?*Node,

    fn init(value: Lexeme, allocator: Allocator) !*Node {
        var node = try allocator.create(Node);
        node.*.value = value;
        node.*.left = null;
        node.*.right = null;
        return node;
    }

    fn sum(self: *Node) Lexeme {
        if (self.*.value.kind == LexemeTypeTag.number) return self.*.value;
        return lexemeF.operate(self.*.value, self.*.left.?.*.sum(), self.*.right.?.*.sum());
    }
    /// Errors:
    ///     If a new node cannot be allocated.
    fn allocateNode(allocator: Allocator) !*Node {
        return allocator.create(Node);
    }

    /// Deallocate a node. Node must have been allocated with `allocator`.
    ///
    /// Arguments:
    ///     node: Pointer to the node to deallocate.
    ///     allocator: Dynamic memory allocator.
    pub fn destroyNode(self: *Node, node: *Node, allocator: Allocator) void {
        assert(self.containsNode(node));
        allocator.destroy(node);
    }
};

pub fn Tree() type {
    return struct {
        const Self = @This();
        root: Node,

        fn makeTreefromLexemes(lexemes: []Lexeme, size: usize, allocator: Allocator) !Node {
            var root = try Node.init(lexemes[1], allocator);
            var leftN = Node.init(lexemes[0], allocator) catch |err| {
                std.debug.print("err {any}\n", .{err});
                return err;
            };

            var rightN = Node.init(lexemes[2], allocator) catch |err| {
                std.debug.print("err {any}\n", .{err});
                return err;
            };
            root.*.left = leftN;
            root.*.right = rightN;

            var i: usize = 3;
            while (i < size) {
                var currentNode = Node.init(lexemes[i], allocator) catch |err| {
                    std.debug.print("err {any}\n", .{err});
                    return err;
                };

                if (currentNode.*.value.value.operator.kind == OperatorTag.mul or currentNode.*.value.value.operator.kind == OperatorTag.div) {
                    var subRoot = currentNode;
                    var newRightNode = Node.init(lexemes[i + 1], allocator) catch |err| {
                        std.debug.print("err {any}\n", .{err});
                        return err;
                    };
                    var newLeftNode = Node.init(lexemes[i - 1], allocator) catch |err| {
                        std.debug.print("err {any}\n", .{err});
                        return err;
                    };
                    subRoot.*.right = newRightNode;
                    subRoot.*.left = newLeftNode;
                    var k = i + 2;
                    while (k < size) {
                        var newNode = Node.init(lexemes[k], allocator) catch |err| {
                            std.debug.print("err {any}\n", .{err});
                            return err;
                        };
                        var newSubRightNode = Node.init(lexemes[k + 1], allocator) catch |err| {
                            std.debug.print("err {any}\n", .{err});
                            return err;
                        };

                        newNode.*.right = newSubRightNode;
                        newNode.*.left = subRoot;
                        subRoot = newNode;
                        k += 2;
                    }
                    root.*.right = subRoot;
                    i = k;
                } else {
                    var newNode = currentNode;
                    var newRightNode = Node.init(lexemes[i + 1], allocator) catch |err| {
                        std.debug.print("err {any}\n", .{err});
                        return err;
                    };

                    newNode.*.right = newRightNode;
                    newNode.*.left = root;
                    root = newNode;
                    i += 2;
                }
            }

            return root.*;
        }

        pub fn init(lexemes: []Lexeme, size: usize, allocator: Allocator) !Self {
            var root = try makeTreefromLexemes(lexemes, size, allocator);
            return Self{
                .root = root,
            };
        }

        pub fn log(self: *Self) void {
            var root = &self.*.root;
            while (root.left != null) {
                // std.debug.print("\nnode {any}\n\n", .{root.value});
                root.value.log();
                // std.debug.print("\nright {any}\n\n", .{root.right.?.value});
                root.right.?.value.log();
                root = root.left.?;
            }
            // std.debug.print("stopped\n", .{});
            root.value.log();
        }
    };
}

//-------------------------
const operatorF = @import("operator.zig");
const Operator = operatorF.Operator;
const OperatorTag = operatorF.OperatorTag;
const OperatorError = operatorF.OperatorError;
//------------------------

//-------------------------
const lexemeF = @import("lexeme.zig");
const Lexeme = lexemeF.Lexeme;
const LexemeTypeTag = lexemeF.LexemeTypeTag;
//-------------------------

fn executeExpr(lexemes: []Lexeme, allocator: Allocator) !void {
    var size = lexemes.len;
    var tree = try Tree().init(lexemes, size, allocator);

    var result = tree.root.sum();
    result.log();
}

fn makeExpr(bufferStream: []const u8, size: usize, allocator: Allocator) ![]Lexeme {
    var lexemes = try Lexer.fromBufferStream(allocator, bufferStream, size);

    std.debug.print("len {d}\n", .{lexemes.len});
    _ = syntax.syntaxAnalyzer(lexemes, lexemes.len) catch |err| {
        std.debug.print("invalid syntax err: {any}\n", .{err});
    };

    return lexemes;
}

pub fn main() !void {
    var allocator = gpa(.{}){};

    while (true) {
        const stdin = std.io.getStdIn().reader();
        var buf_reader = std.io.bufferedReader(stdin);
        const reader = buf_reader.reader();

        var buf: [100]u8 = undefined; //TODO: Adjust buffer size as needed
        var line = try reader.readUntilDelimiterOrEof(&buf, '\n');
        const size: usize = line.?.len;
        const buffer: []u8 = line.?;

        var expr = try makeExpr(buffer, size, allocator.allocator());
        try executeExpr(expr, allocator.allocator());
    }
}
test "simple test" {}
