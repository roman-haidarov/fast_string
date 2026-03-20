require "bundler/gem_tasks"
require "rake/extensiontask"
require "rake/testtask"

spec = Gem::Specification.load('fast_string.gemspec')

Rake::ExtensionTask.new("fast_string", spec) do |ext|
  ext.lib_dir = "lib/fast_string"
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["spec/**/*_spec.rb"]
end

desc "Run benchmarks"
task :benchmark do
  exec "ruby benchmark/benchmark.rb"
end

task :default => [:compile, :test]
