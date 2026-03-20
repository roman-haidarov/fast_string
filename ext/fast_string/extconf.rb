require 'mkmf'

# Add optimization flags for maximum performance
$CFLAGS += " -O3 -funroll-loops -ffast-math"

# Additional performance flags
$CFLAGS += " -DNDEBUG"  # Disable debug assertions

# SIMD support detection and flags
def check_simd_support
  # Check for AVX2 support
  if try_compile("#include <immintrin.h>\nint main() { __m256i v = _mm256_setzero_si256(); return 0; }")
    puts "AVX2 support detected"
    $CFLAGS += " -mavx2"
  # Check for SSE4.1 support
  elsif try_compile("#include <smmintrin.h>\nint main() { __m128i v = _mm_setzero_si128(); return 0; }")
    puts "SSE4.1 support detected"
    $CFLAGS += " -msse4.1"
  else
    puts "No advanced SIMD support detected, using scalar fallback"
  end
  
  # Check for ARM NEON on ARM platforms
  if RUBY_PLATFORM =~ /arm|aarch64/i
    if try_compile("#include <arm_neon.h>\nint main() { uint8x16_t v = vdupq_n_u8(0); return 0; }")
      puts "ARM NEON support detected"
      $CFLAGS += " -mfpu=neon" if RUBY_PLATFORM !~ /aarch64/i
    end
  end
end

# Enable native arch optimizations if supported
if try_compile("int main() { return 0; }", "-march=native")
  $CFLAGS += " -march=native"
  puts "Using -march=native for optimal performance"
else
  puts "march=native not supported, using manual SIMD detection"
  check_simd_support
end

# Check for required headers and functions
have_header('immintrin.h')
have_header('smmintrin.h') 
have_header('arm_neon.h')

# Ensure we have string.h and required Ruby functions
abort "string.h is required" unless have_header('string.h')
abort "Ruby encoding functions not available" unless have_func('rb_enc_get', 'ruby/encoding.h')

create_makefile('fast_string/fast_string')
