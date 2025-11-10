const std = @import("std");

pub fn parse_fix_fields(message: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    var fields = std.ArrayList([]const u8).init(allocator);
    errdefer fields.deinit();

    var i: usize = 0;
    while (i < message.len) {
        const start = i;
        while (i < message.len and message[i] != 0x01) {
            i += 1;
        }
        const field = message[start..i];
        if (field.len > 0) {
            try fields.append(field);
        }
        if (i < message.len) {
            i += 1;
        }
    }

    return fields.toOwnedSlice();
}

pub fn crc32(data: []const u8) u32 {
    var crc: u32 = 0xFFFFFFFF;
    
    for (data) |byte| {
        crc ^= @as(u32, byte);
        var j: u32 = 0;
        while (j < 8) : (j += 1) {
            if (crc & 1 != 0) {
                crc = (crc >> 1) ^ 0xEDB88320;
            } else {
                crc >>= 1;
            }
        }
    }
    
    return crc ^ 0xFFFFFFFF;
}
