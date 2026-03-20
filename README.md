# fast_string

High-performance Ruby `String` extensions implemented in **C**.

[![Gem Version](https://badge.fury.io/rb/fast_string.svg)](https://badge.fury.io/rb/fast_string)
[![Ruby](https://github.com/roman-haidarov/fast_string/workflows/Ruby/badge.svg)](https://github.com/roman-haidarov/fast_string/actions)

Optimized string methods for high-throughput workloads: log processing, CSV parsing, HTTP parsing, text analytics, streaming pipelines.

## Installation

```ruby
gem 'fast_string'
```

## Usage

```ruby
require 'fast_string'

"hello".fs_count("l")                     #=> 2
"line1\nline2\nline3".fs_lines            #=> 2
"   \t\n  ".fs_blank?                     #=> true
"  hello  ".fs_trim                       #=> "hello"
"hello\nworld".fs_byte_replace("\n", " ") #=> "hello world"
"hello\r\nworld".fs_byte_delete("\r")     #=> "hello\nworld"

data.fs_each_line { |line| puts line }
```

## API

| Method | Ruby equivalent | What it does |
|---|---|---|
| `fs_count(char)` | `str.count(char)` | Count occurrences of a single byte |
| `fs_lines` | `str.count("\n")` | Count newline characters |
| `fs_blank?` | `str.strip.empty?` | Check if string is whitespace-only |
| `fs_trim` | `str.strip` | Strip whitespace (zero-copy) |
| `fs_byte_replace(from, to)` | `str.tr(from, to)` | Replace one byte with another |
| `fs_byte_delete(char)` | `str.delete(char)` | Delete all occurrences of a byte |
| `fs_each_line { }` | `str.each_line { }` | Iterate lines via memchr |

All methods operate at **byte level** using `memchr` and direct memory access. Single-character arguments only.

`fs_trim` returns a zero-copy shared substring — no `memcpy` unlike Ruby's `strip`.

`fs_byte_replace` and `fs_byte_delete` return new strings; originals are not mutated.

## Benchmark

Apple Silicon (M1), Ruby 2.7. Numbers are **times faster** than Ruby stdlib equivalent:

| Method | 42KB | 10MB | 9.6MB CSV | 38MB Log | 5.8MB Unicode |
|---|---|---|---|---|---|
| `fs_count` | 1.8x | 7.9x | 6.2x | 9.0x | 9.2x |
| `fs_lines` | 1.9x | 7.9x | 6.2x | 9.0x | 9.1x |
| `fs_blank?` | 4.1x | 4.0x | 4.0x | 4.0x | 4.1x |
| `fs_trim` | 3.8x | 4.0x | 4.0x | 3.9x | 4.0x |
| `fs_byte_replace` | 5.7x | 15.0x | 13.0x | **16.1x** | **67.9x** |
| `fs_byte_delete` | 3.8x | 13.5x | 12.2x | **15.1x** | **33.2x** |
| `fs_each_line` | 1.1x | 1.1x | 1.0x | 1.1x | 1.0x |

`fs_byte_replace` and `fs_byte_delete` show the largest gains because Ruby's `tr` and `delete` go through the encoding layer per character, while fast_string uses `memchr` to skip non-matching regions in bulk.

```bash
ruby benchmark/benchmark.rb
```

## Requirements

- Ruby >= 2.7.0
- C compiler (GCC, Clang)

## Platforms

Linux, macOS, BSD, ARM (Apple Silicon), x86_64

## Development

```bash
bundle install
rake compile
ruby test_basic.rb
ruby benchmark/benchmark.rb
```

## License

MIT
