defmodule ZigNifs do
  @moduledoc false
  
  def parse_fix_message(_message), do: :erlang.nif_error(:nif_not_loaded)
  def calculate_checksum(_data), do: :erlang.nif_error(:nif_not_loaded)
  
  @on_load :load_nifs

  def load_nifs do
    :ok
  end
end

defmodule ZigNifs.Impl do
  use Zigler, otp_app: :realtime_processor

  ~Z"""
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
  """

  ~Z"""
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
  """
end

