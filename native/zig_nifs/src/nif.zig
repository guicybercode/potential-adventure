const std = @import("std");
const zigler = @import("zigler");

pub const Beam = zigler.Beam;
pub const e = zigler.e;

const parser = @import("parser.zig");
const checksum = @import("checksum.zig");

pub fn parse_fix_message(env: Beam, message: []const u8) !Beam.term {
    const allocator = std.heap.page_allocator;
    const fields = try parser.parse_fix_fields(message, allocator);
    defer allocator.free(fields);

    var result = try e.make_list(env);
    for (fields) |field| {
        const field_term = try e.make_binary(env, field);
        result = try e.list_prepend(env, field_term, result);
    }
    result = try e.list_reverse(env, result);
    return result;
}

pub fn calculate_checksum(env: Beam, data: []const u8) !Beam.term {
    const crc = checksum.crc32(data);
    return e.make_u32(env, crc);
}

pub fn nif_init(_: Beam) void {}

pub const nifs = .{
    .parse_fix_message = .{
        .arity = 1,
        .function = parse_fix_message,
    },
    .calculate_checksum = .{
        .arity = 1,
        .function = calculate_checksum,
    },
};

pub const name = "zig_nifs";
pub const version = "0.1.0";
pub const min_otp_version = "24";
