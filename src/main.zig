const std = @import("std");
const assert = std.debug.assert;

//-------------------------
const lexerF = @import("lexer.zig");
const Lexer = lexerF.Lexer;
const LexicalError = lexerF.LexicalError;
//-------------------------
const Allocator = std.mem.Allocator;
pub fn Tree(comptime T: type) type {
    return struct {
        const Self = @This();
        root: Node,

        /// Node inside the tree.
        pub const Node = struct {
            value: T,
            left: ?*Node,
            right: ?*Node,

            fn init(value: T) Node {
                return Node{
                    .value = value,
                    .left = null,
                    .right = null,
                };
            }
            // fn init(value: u8) Node {
            //     return Node{
            //         .value = value,
            //         .left = &Node{
            //             .value = value - 1,
            //             .left = null,
            //             .right = null,
            //         },
            //         .right = &Node{
            //             .value = value + 1,
            //             .left = null,
            //             .right = null,
            //         },
            //     };
            // }
        };

        pub fn init(value: T) Self {
            return Self{
                .root = Node.init(value),
            };
        }
        /// Errors:
        ///     If a new node cannot be allocated.
        pub fn allocateNode(self: *Self, allocator: Allocator) !*Node {
            _ = self;
            return allocator.create(Node);
        }

        /// Deallocate a node. Node must have been allocated with `allocator`.
        ///
        /// Arguments:
        ///     node: Pointer to the node to deallocate.
        ///     allocator: Dynamic memory allocator.
        pub fn destroyNode(tree: *Self, node: *Node, allocator: Allocator) void {
            assert(tree.containsNode(node));
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
        pub fn createNode(tree: *Self, value: T, allocator: Allocator) !*Node {
            var node = try tree.allocateNode(allocator);
            node.* = Node.init(value);
            return node;
        }

        pub fn addLeft(self: *Self, node: *Node) void {
            self.root.left = node;
        }

        pub fn addRight(self: *Self, node: *Node) void {
            self.root.right = node;
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var tree = Tree(u32).init(1);
    var node = try tree.createNode(8, allocator);
    tree.addLeft(node);
    std.debug.print("{d} {d}\n", .{ tree.root.value, tree.root.left.?.value });
    // _ = tree;
}

test "simple test" {}
