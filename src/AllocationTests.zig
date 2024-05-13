const std = @import("std");
const expect = std.testing.expect;
const windows = @cImport({
    @cInclude("Windows.h");
});
pub fn main() !void {
    const allocator = std.heap.page_allocator;
    std.debug.print("Before allocation. ", .{});
    const m1 = getTotalHeapSize(allocator);
    std.debug.print("Heap memory: {any}\n", .{m1});

    const heapAllocator = std.heap.raw_c_allocator;
    const memory = try heapAllocator.alloc(u8, 1000);

    for (memory) |i| {
        memory[i] = 42;
    }

    const m2 = getTotalHeapSize(allocator);
    std.debug.print("After allocation. ", .{});
    std.debug.print("Heap memory: {any}\n", .{m2});

    std.debug.print("Before free. ", .{});
    std.debug.print("Heap memory: {any}\n", .{getTotalHeapSize(allocator)});
    heapAllocator.free(memory);
    std.debug.print("After free. ", .{});
    std.debug.print("Heap memory: {any}\n", .{getTotalHeapSize(allocator)});
}

fn getTotalHeapSize(allocator: std.mem.Allocator) !usize {
    var totalHeapSize: usize = 0;
    var numberOfHeaps: windows.DWORD = 0;
    var hHeaps: []windows.HANDLE = undefined;

    // Get the number of heaps in the process
    numberOfHeaps = windows.GetProcessHeaps(0, null);

    // Create an array to hold the heap handles
    hHeaps = try allocator.alloc(windows.HANDLE, numberOfHeaps);
    defer allocator.free(hHeaps);
    
    // Get the handles to all heaps in the process
    _ = windows.GetProcessHeaps(numberOfHeaps, &hHeaps[0]);

    // Enumerate all heaps
    for (hHeaps) |hHeap| {
        var heapEntry: windows.PROCESS_HEAP_ENTRY = undefined;
        heapEntry.lpData = null;

        // Enumerate the memory blocks in the heap
        while (windows.HeapWalk(hHeap, &heapEntry) != 0) {
            // Check if it is a valid memory block
            if ((heapEntry.wFlags & windows.PROCESS_HEAP_ENTRY_BUSY) != 0) {
                // Get the size of the memory block
                totalHeapSize += windows.HeapSize(hHeap, 0, heapEntry.lpData);
            }
        }

        // If the enumeration fails, break out of the loop
        if (windows.GetLastError() != windows.ERROR_NO_MORE_ITEMS) {
            std.debug.print("Failed to walk the heap\n", .{});
            break;
        }
    }

    return totalHeapSize;
}

fn say_heap(word: []const u8, allocator: std.mem.Allocator) !void {
    std.debug.print("Heap memory {s}: {any}\n", .{word, getTotalHeapSize(allocator)});
}

test "Create array using heap" {
    const allocator = std.heap.raw_c_allocator;
    try say_heap("before allocation", allocator);
    
    // const start_memory = getTotalHeapSize(allocator);

    const memory = try allocator.alloc(u8, 100);
    try say_heap("after allocation", allocator);

    memory[1] = 2;
    try say_heap("after changing one element in array", allocator);

    const memory1 = memory[0..88];
    try say_heap("after creating slices from array", allocator);

    // Heap-allocated dynamic array using ArrayList
    var numbers = std.ArrayList(u32).init(allocator);
    try say_heap("after allocation dynamic but empty for now array", allocator);

    try numbers.append(10);
    try say_heap("after adding first element to array", allocator);

    try numbers.append(20);
    try say_heap("after adding second element to array", allocator);

    try numbers.append(30);
    try say_heap("after adding third element to array", allocator);

    try expect(memory1.len == 88);
    try expect(memory.len == 100);
    try expect(memory[1] == 2);
    try expect(numbers.items.len == 3);

    allocator.free(memory);
    // allocator.free(memory1);
    try say_heap("after freeing fixed size array", allocator);
    numbers.deinit();
    try say_heap("after deinitialising dynamic array", allocator);
    std.debug.print("Heap memory: {any}\n", .{getTotalHeapSize(allocator)});
    std.debug.print("Heap memory: {any}\n", .{getTotalHeapSize(allocator)});
    std.debug.print("Heap memory: {any}\n", .{getTotalHeapSize(allocator)});
    std.debug.print("Heap memory: {any}\n", .{getTotalHeapSize(allocator)});
    std.debug.print("Heap memory: {any}\n", .{getTotalHeapSize(allocator)});

    try say_heap("after all 1", allocator);
    try say_heap("after all 2", allocator);
    try say_heap("after all 3", allocator);
    try say_heap("after all 4", allocator);
    try say_heap("after all 5", allocator);
    try say_heap("after all 6", allocator);    

    // const end_memory = getTotalHeapSize(allocator);
    // const result: usize = @as(usize, end_memory) - @as(usize, start_memory);
    // std.debug.print("s: {!}, e: {!}\n", .{, });
    // std.debug.print("Memory difference", .{result});

    // try expect(end_memory == start_memory);
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
