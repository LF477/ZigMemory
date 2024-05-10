const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {}

pub fn Increment(i: u8) !void {
    i += 1;
}
pub fn IncrementP(i: *u8) !void {
    i.* += 1;
}

test "Integer passed by value" {
    var i: u8 = 0;
    //try Increment(i); // Function arguments are always constant.
    // Converting it to a pointer is the correct way of making it mutable
    try expect(i == 0);
    try IncrementP(&i);
    try expect(i == 1);
}

const CustomStruct = struct { i: i32 };
fn IncrementS(self: CustomStruct) !void {
    self.i += 1;
}
fn IncrementSP(self: *CustomStruct) !void {
    self.*.i += 1;
}

test "Custom struct passed by value" {
    var cstruct = CustomStruct{
        .i = 1,
    };
    //try IncrementS(cstruct); // Function arguments are always constant.
    // Converting it to a pointer is the correct way of making it mutable
    try expect(cstruct.i == 1);
    try IncrementSP(&cstruct);
    try expect(cstruct.i == 2);
}
