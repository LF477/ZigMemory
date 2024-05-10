const std = @import("std");
const expect = std.testing.expect;
const c = @cImport({
    @cInclude("malloc.h");
});

pub fn main() !void {}

test "Create array using heap" {
    const allocator = std.heap.page_allocator;

    const memory = try allocator.alloc(u8, 100);

    //defer allocator.free(memory);

    memory[1] = 2;
    const memory1 = memory[0..88];

    // Heap-allocated dynamic array using ArrayList
    var numbers = std.ArrayList(u32).init(allocator);
    defer numbers.deinit();

    try numbers.append(10);
    try numbers.append(20);
    try numbers.append(30);

    try expect(memory1.len == 88);
    try expect(memory.len == 100);
    try expect(memory[1] == 2);
    // try expect(memory[0] == 170);
    try expect(@TypeOf(memory) == []u8);
    try expect(numbers.items.len == 3);

    // std.debug.print("\n{any}\n\n", .{memory});
    allocator.free(memory);
    // errdefer std.debug.panic("\nThese array already not exists... Rest in Peace!\n", .{});
    // std.debug.print("\n{any}\n\n", .{memory});
    // Trying to show array with name memory gives us error
    // It means it erases it

    // DOCKER GIVES ERROR WHILE IN TERMINAL IT WORKS...
    // const memory2 = try allocator.create(u8);
    // allocator.destroy(memory2);
    // const memory3 = try allocator.create(u8);
    // defer allocator.destroy(memory3);

    // try std.testing.expect(memory2 == memory3); // memory reuse
    // DOCKER GIVES ERROR WHILE IN TERMINAL IT WORKS...
}

test "Heap allocator create/destroy (Single item)" {
    const byte = try std.heap.page_allocator.create(u8);
    defer std.heap.page_allocator.destroy(byte);
    byte.* = 128;
    // DOCKER GIVES ERROR WHILE IN TERMINAL IT WORKS...
    // std.heap.page_allocator.destroy(byte);
    // const byte1 = try std.heap.page_allocator.create(u8);
    // byte1.* = 128;
    // defer std.heap.page_allocator.destroy(byte1);
    // try expect(byte == byte1);
    // DOCKER GIVES ERROR WHILE IN TERMINAL IT WORKS...
}

test "Create array using stack" {
    // In Zig, you can allocate memory on the stack by declaring variables with a fixed size.
    // These variables are known as stack-allocated variables, and their lifetime is bound to the scope in which they are defined.
    const Point = struct {
        x: f32,
        y: f32,
    };

    var point: Point = .{
        .x = 1.5,
        .y = 2.7,
    };

    point.x += 3.0;
    point.y -= 1.2;

    var numbers: [5]u16 = .{ 10, 20, 30, 40, 50 };
    numbers[2] = 999;
    // 'numbers' and 'point' is automatically deallocated when it goes out of scope
    try expect((numbers.len == 5));
    try expect((point.x == 4.5));
    try expect((point.y == 1.5));
}

//////////////////  OTHERS HEAP ALLOCATORS //////////////////

test "fixed buffer allocator" { // Exceeds fixed number => error
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const memory = try allocator.alloc(u8, 1000);
    // const memory1 = try allocator.alloc(u8, 1000); Will be error
    defer allocator.free(memory);

    try expect(memory.len == 1000);
    try expect(@TypeOf(memory) == []u8);
}

test "arena allocator" { // like several buffers but different sizes (And can be freed all together)
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    _ = try allocator.alloc(u8, 1);
    _ = try allocator.alloc(u8, 10);
    _ = try allocator.alloc(u8, 100);
}

test "GPA" { // safe allocator that can prevent double-free, use-after-free and can detect leaks
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
    }

    const bytes = try allocator.alloc(u8, 100);
    defer allocator.free(bytes);
}
