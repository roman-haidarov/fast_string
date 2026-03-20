#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'fast_string'

pass = 0
fail = 0

def test_method(name, expected, actual)
  if expected == actual
    puts "  ✅ #{name}"
    return true
  else
    puts "  ❌ #{name}: expected #{expected.inspect}, got #{actual.inspect}"
    return false
  end
end

puts "fs_count"
pass += 1 if test_method("newlines", 2, "hello\nworld\ntest".fs_count("\n"))
pass += 1 if test_method("repeated char", 3, "hello".fs_count("l"))
pass += 1 if test_method("not found", 0, "hello".fs_count("z"))
pass += 1 if test_method("empty string", 0, "".fs_count("a"))
pass += 1 if test_method("vs Ruby count", "hello".count("l"), "hello".fs_count("l"))
puts

puts "fs_lines"
pass += 1 if test_method("two newlines", 2, "hello\nworld\ntest".fs_lines)
pass += 1 if test_method("empty", 0, "".fs_lines)
pass += 1 if test_method("no newlines", 0, "hello".fs_lines)
pass += 1 if test_method("trailing newline", 3, "a\nb\nc\n".fs_lines)
puts

puts "fs_blank?"
pass += 1 if test_method("whitespace", true, "   \t\n\r  ".fs_blank?)
pass += 1 if test_method("not blank", false, "hello".fs_blank?)
pass += 1 if test_method("empty", true, "".fs_blank?)
pass += 1 if test_method("single space", true, " ".fs_blank?)
pass += 1 if test_method("mixed with text", false, "  x  ".fs_blank?)
pass += 1 if test_method("vs Ruby", "  \t\n".strip.empty?, "  \t\n".fs_blank?)
puts

puts "fs_each_line"
lines = []
"hello\nworld\ntest".fs_each_line { |l| lines << l }
pass += 1 if test_method("basic", ["hello\n", "world\n", "test"], lines)
pass += 1 if test_method("vs Ruby each_line", "a\nb".each_line.to_a, "a\nb".fs_each_line.to_a)
empty_lines = []
"".fs_each_line { |l| empty_lines << l }
pass += 1 if test_method("empty string", [], empty_lines)
pass += 1 if test_method("enumerator", true, "abc".fs_each_line.is_a?(Enumerator))
single = []
"no newline".fs_each_line { |l| single << l }
pass += 1 if test_method("no newline", ["no newline"], single)
puts

puts "fs_trim"
pass += 1 if test_method("both sides", "hello", "  hello  ".fs_trim)
pass += 1 if test_method("tabs and newlines", "hello", "\t\nhello\r\n".fs_trim)
pass += 1 if test_method("no whitespace", "hello", "hello".fs_trim)
pass += 1 if test_method("all whitespace", "", "   \t\n  ".fs_trim)
pass += 1 if test_method("empty", "", "".fs_trim)
pass += 1 if test_method("vs Ruby strip", "  hello  ".strip, "  hello  ".fs_trim)
pass += 1 if test_method("inner whitespace", "hello world", "  hello world  ".fs_trim)
puts

puts "fs_byte_replace"
pass += 1 if test_method("basic", "hello world", "hello\nworld".fs_byte_replace("\n", " "))
pass += 1 if test_method("no match", "hello", "hello".fs_byte_replace("z", "x"))
pass += 1 if test_method("all match", "bbb", "aaa".fs_byte_replace("a", "b"))
pass += 1 if test_method("same byte", "hello", "hello".fs_byte_replace("l", "l"))
pass += 1 if test_method("empty", "", "".fs_byte_replace("a", "b"))
pass += 1 if test_method("vs Ruby tr", "hello".tr("l", "r"), "hello".fs_byte_replace("l", "r"))
puts

puts "fs_byte_delete"
pass += 1 if test_method("basic", "hllo", "hello".fs_byte_delete("e"))
pass += 1 if test_method("no match", "hello", "hello".fs_byte_delete("z"))
pass += 1 if test_method("all match", "", "aaa".fs_byte_delete("a"))
pass += 1 if test_method("empty", "", "".fs_byte_delete("a"))
pass += 1 if test_method("delete newlines", "helloworld", "hello\nworld\n".fs_byte_delete("\n"))
pass += 1 if test_method("delete CR", "hello\nworld\n", "hello\r\nworld\r\n".fs_byte_delete("\r"))
pass += 1 if test_method("vs Ruby delete", "hello".delete("l"), "hello".fs_byte_delete("l"))
puts

puts "Done: #{pass} passed"
