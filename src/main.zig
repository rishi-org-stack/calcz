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

    /// Allocate and initialize a node and its value.
    ///
    /// Arguments:
    ///     value: Value (aka weight, key, etc.) of newly created node.
    ///     allocator: Dynamic memory allocator.
    ///
    /// Returns:
    ///     A pointer to the new node.
    ///
    /// Errors:
    ///     If a new node cannot be allocated.
    pub fn createNode(self: *Node, value: Lexeme, allocator: Allocator) !*Node {
        var node = try self.allocateNode(allocator);
        node.* = Node.init(value);
        return node;
    }
};
pub fn Tree() type {
    return struct {
        const Self = @This();
        root: Node,

        pub fn init(root: Node) Self {
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
const OperatorError = operatorF.OperationError;
//------------------------
pub fn makeTreefromLexemes(lexemes: []Lexeme, size: usize, allocator: Allocator) !Tree() {
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

        if (currentNode.*.value.value.operator.kind == OperatorTag.mul) {
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
    var tree = Tree().init(root.*);

    return tree;
}

//-------------------------
const lexemeF = @import("lexeme.zig");
const Lexeme = lexemeF.Lexeme;
const LexemeTypeTag = lexemeF.LexemeTypeTag;
//-------------------------

pub fn main() !void {
    var allocator = gpa(.{}){};
    var lexemes = try Lexer.fromBufferStream(allocator.allocator(), "9 + 1 + 2 - 4 * 2 / 2", 21);

    std.debug.print("len {d}\n", .{lexemes.len});
    _ = syntax.syntaxAnalyzer(lexemes, lexemes.len) catch |err| {
        std.debug.print("invalid syntax err: {any}\n", .{err});
        return;
    };

    var size = lexemes.len;
    var tree = try makeTreefromLexemes(lexemes, size, allocator.allocator());
    // tree.log();
    var result = tree.root.sum();
    result.log();
}

test "simple test" {}
