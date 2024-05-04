const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {}

test "Array Passed By Reference"{
    var value = [3]u8{ 1, 2, 3 };
    
    for (0.., value) |i, val| {
        value[i] = val + 1;
    }

    try expect(value[0] == 2);
    try expect(value[1] == 3);
    try expect(value[2] == 4);
}

const Cstruct = struct {
    Value:i32,
    fn Increment(self: *Cstruct) !void {
        self.Value = self.Value + 1;
    }
};

test "Custom Class Passed By Reference"{
    var customClass = Cstruct{.Value=10};
    
    try customClass.Increment();

    try expect(customClass.Value == 11);
}