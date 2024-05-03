const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    
    var array = [5]i32{ 1, 2, 3, 4, 5 };
    
    const ptr: *[3]i32 = array[1..4];

    const pointer = &ptr;
    const pointer_to_first = &ptr[0];
    

    print("Pointers: {}, {}\n", .{pointer, pointer_to_first});

    print("len: {}\n", .{ptr.len});
    print("first: {}\n", .{ptr[0]});
    for (ptr) |elem| {
        print("elem: {}\n", .{elem});
    }

}