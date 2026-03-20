require 'benchmark'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'fast_string'

small_data = "hello\nworld\ntest line with some text here\n" * 1000
medium_data = "This is a longer test line with various characters and symbols @#$%^&*().\nAnother line here with different content and more text to process.\nYet another line with even more content to make this realistic.\n" * 50000
csv_data = ("user_id,name,email,age,city,country\n" + "12345,John Doe,john@example.com,30,New York,USA\n" * 200000).freeze
log_data = ("2024-01-01T10:30:45.123Z [INFO ] ApplicationController - Processing request\n" * 500000).freeze
mixed_unicode = "ASCII text here with some unicode: тест, 测试, مرحبا, こんにちは\n" * 100000

puts "FastString Benchmark Results"
puts "=" * 50
puts

puts "Test data sizes:"
puts "Small:  #{small_data.length} bytes"
puts "Medium: #{medium_data.length} bytes"
puts "CSV:    #{csv_data.length} bytes"
puts "Log:    #{log_data.length} bytes"
puts "Mixed:  #{mixed_unicode.length} bytes"
puts

test_cases = [
  ["Small Data", small_data],
  ["Medium Data", medium_data],
  ["CSV Data", csv_data],
  ["Log Data", log_data],
  ["Mixed Unicode", mixed_unicode]
]

test_cases.each do |name, data|
  puts "#{name} (#{data.length} bytes):"
  puts "-" * 30

  puts "Counting newline characters:"
  Benchmark.bm(19) do |x|
    x.report("ruby count") { 1000.times { data.count("\n") } }
    x.report("fs_count")   { 1000.times { data.fs_count("\n") } }
    x.report("fs_lines")   { 1000.times { data.fs_lines } }
  end
  puts

  whitespace_data = "   \t\n\r  " * (data.length / 20)
  puts "Checking blank string:"
  Benchmark.bm(19) do |x|
    x.report("ruby strip.empty?") { 1000.times { whitespace_data.strip.empty? } }
    x.report("fs_blank?")         { 1000.times { whitespace_data.fs_blank? } }
  end
  puts

  puts "Stripping whitespace:"
  Benchmark.bm(19) do |x|
    x.report("ruby strip") { 1000.times { whitespace_data.strip } }
    x.report("fs_trim")    { 1000.times { whitespace_data.fs_trim } }
  end
  puts

  puts "Replacing byte (\\n -> space):"
  Benchmark.bm(19) do |x|
    x.report("ruby tr")          { 100.times { data.tr("\n", " ") } }
    x.report("fs_byte_replace")  { 100.times { data.fs_byte_replace("\n", " ") } }
  end
  puts

  puts "Deleting byte (\\r):"
  crlf_data = data.gsub("\n", "\r\n")
  Benchmark.bm(19) do |x|
    x.report("ruby delete")     { 100.times { crlf_data.delete("\r") } }
    x.report("fs_byte_delete")  { 100.times { crlf_data.fs_byte_delete("\r") } }
  end
  puts

  puts "Iterating lines:"
  Benchmark.bm(19) do |x|
    x.report("ruby each_line") { 100.times { data.each_line { |line| line.length } } }
    x.report("fs_each_line")   { 100.times { data.fs_each_line { |line| line.length } } }
  end

  puts "=" * 50
  puts
end
