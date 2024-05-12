const std = @import("std");
const expect = std.testing.expect;
const heap = @cImport({
    @cInclude("Windows.h");
});
pub fn main() !void {
    const allocator = std.heap.page_allocator;
    std.debug.print("Before allocation. ", .{});

    std.debug.print("Heap memory: {any}\n", .{GetTotalHeapSize()});
    const memory = try allocator.alloc(u8, 100);
    std.debug.print("After allocation. ", .{});
    std.debug.print("Heap memory: {any}\n", .{GetTotalHeapSize()});


    memory[1] = 2;

    std.debug.print("Before free. ", .{});
    std.debug.print("Heap memory: {any}\n", .{GetTotalHeapSize()});
    allocator.free(memory);
    std.debug.print("After free. ", .{});
    std.debug.print("Heap memory: {any}\n", .{GetTotalHeapSize()});
}

pub fn GetTotalHeapSize() c_ulonglong {
    var hHeap: heap.HANDLE = undefined;
    var totalHeapSize: c_ulonglong = 0;
    var heapEntry: heap.PROCESS_HEAP_ENTRY = undefined;
    var success: c_int = undefined;
    var numberOfHeaps: c_ulong = undefined;

    // ' Get the number of heaps in the process
    numberOfHeaps = heap.GetProcessHeaps(0, null);

    // ' Create an array to hold the heap handles
    var hHeaps: [200]heap.HANDLE = undefined;
    // ReDim hHeaps(numberOfHeaps - 1)

    // ' Get the handles to all heaps in the process
    _ = heap.GetProcessHeaps(numberOfHeaps, &hHeaps[0]);
    // ' Enumerate all heaps
    for (0..numberOfHeaps) |i| {
        // ' Get a handle to the heap
        hHeap = hHeaps[i];

        // ' Initialize the heap entry structure
        heapEntry.lpData = null;

        // ' Enumerate the memory blocks in the heap
        success = heap.HeapWalk(hHeap, &heapEntry);
        if (success != 0) {
            // ' Check if it is a valid memory block
            // std.debug.print("Heap Entry wFlags: {any}, Heap Entry Busy: {any}\n", .{heapEntry.wFlags, heap.PROCESS_HEAP_ENTRY_BUSY});
            // std.debug.print("Res: {any}\n", .{1 & 4});
            if ((heapEntry.wFlags & heap.PROCESS_HEAP_ENTRY_BUSY) != 0) {
                // ' Get the size of the memory block
                const oneheapsize = heap.HeapSize(hHeap, 0, heapEntry.lpData);
                // std.debug.print("One heap memory: {any}\n", .{oneheapsize});
                totalHeapSize += oneheapsize;
            }
        } 
        else {
            // ' If the enumeration fails, break out of the loop
            if (heap.GetLastError() != heap.ERROR_NO_MORE_ITEMS) {
                std.debug.print("Failed to walk the heap", .{});
            }
        }
    }
    return totalHeapSize;
}

test "Create array using heap" {
    // const t = "dadd"
    const allocator = std.heap.page_allocator;
    std.debug.print("Before allocation. ", .{});

    std.debug.print("Heap memory: {any}\n", .{GetTotalHeapSize()});
    const memory = try allocator.alloc(u8, 100);
    std.debug.print("After allocation. ", .{});
    std.debug.print("Heap memory: {any}\n", .{GetTotalHeapSize()});


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
    std.debug.print("Before free. ", .{});

    std.debug.print("Heap memory: {any}\n", .{GetTotalHeapSize()});
    allocator.free(memory);
    std.debug.print("After free. ", .{});
    std.debug.print("Heap memory: {any}\n", .{GetTotalHeapSize()});

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
