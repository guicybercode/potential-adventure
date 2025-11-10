const std = @import("std");

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
