const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {}

test "Create array using heap" {
    const allocator = std.heap.page_allocator;

    const memory = try allocator.alloc(u8, 100);
    //defer expect(memory.len == 0);
    //defer std.debug.print("Heap memory: {}\nStack memory: {}\n", .{ @sizeOf(@TypeOf(memory)), @sizeOf([]u8) });
    //defer allocator.free(memory);
    //defer std.debug.print("Heap memory: {}\nStack memory: {}\n", .{ @sizeOf(@TypeOf(memory)), usize });
    //defer expect(memory.len == 100);
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
    try expect(@TypeOf(memory) == []u8);
    try expect(numbers.items.len == 3);
    // const allc = allocator.ptr;
    std.debug.print("\n{}\n{}\n", .{allocator.ptr, memory[1]});
    std.debug.print("\n{}\n{}\n", .{allocator.ptr, memory[1]});
    allocator.free(memory);
    // std.debug.print("Memory {}", .{memory[0]});
    // try expect(memory.len == 0);
    //std.debug.print("\n{}\n{}\n", .{allocator.ptr, memory[1]}); //catch std.debug.print("Error with revealing value", .{});
    // const allc = allocator.ptr;
}

test "Heap allocator create/destroy (Single item)" {
    const byte = try std.heap.page_allocator.create(u8);
    defer std.heap.page_allocator.destroy(byte);
    byte.* = 128;
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
