const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {}

test "Integer_PassedByValue"{
    var i:u8 = 0;
    i += 1;
    try expect(i == 1);
}


const CustomStruct = struct {
    i:i32,
    fn ChangeVal(self: *CustomStruct, value:i32) !void {
        self.i = value;
    }
};

test "Custom struct passed by value"{
    var cstruct = CustomStruct{
        .i = 1,
    };
    try cstruct.ChangeVal(23);
    try expect(cstruct.i == 23);
}