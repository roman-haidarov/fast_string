require 'fast_string/version'

# Load the compiled extension (.so on Linux, .bundle on macOS)
begin
  require 'fast_string/fast_string'
rescue LoadError
  # Fallback for different extension names
  ext_dir = File.expand_path('../fast_string', __FILE__)
  if File.exist?(File.join(ext_dir, 'fast_string.bundle'))
    require File.join(ext_dir, 'fast_string.bundle')
  elsif File.exist?(File.join(ext_dir, 'fast_string.so'))
    require File.join(ext_dir, 'fast_string.so')
  else
    raise LoadError, "Could not find compiled extension"
  end
end

# The C extension will automatically extend String class with fs_ methods
module FastString
  # Module can be used for future utility methods if needed
end
