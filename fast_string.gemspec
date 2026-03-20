require_relative 'lib/fast_string/version'

Gem::Specification.new do |spec|
  spec.name          = "fast_string"
  spec.version       = FastString::VERSION
  spec.authors       = ["Roman Haydarov"]
  spec.email         = ["romnhajdarov@gmail.com"]

  spec.summary       = "High-performance Ruby String extensions implemented in C"
  spec.description   = "Minimal set of optimized string scanning methods for high-throughput workloads like log processing, CSV parsing, HTTP parsing, and text analytics. Pure C implementation with no external dependencies."
  spec.homepage      = "https://github.com/roman-haidarov/fast_string"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    'lib/**/*.rb',
    'ext/**/*.{c,h,rb}',
    'benchmark/**/*.rb',
    'spec/**/*.rb',
    'README.md',
    'LICENSE.txt',
    'CHANGELOG.md'
  ]

  spec.bindir        = "exe"
  spec.executables   = []
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/fast_string/extconf.rb"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rake-compiler", "~> 1.2"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "benchmark-ips", "~> 2.0"
end
