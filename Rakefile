$LOAD_PATH.unshift("lib", *Dir.glob("vendor/*/lib"))

load "depgen/depgen.task"

begin
  require "spec/rake/spectask"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = Dir.glob 'spec/**/*_spec.rb'
  end
rescue LoadError
  $stderr.puts "please install rspec"
end

begin
  require "big_band/integration/rake"
  include BigBand::Integration::Rake
  RoutesTask.new { |t| t.source = "lib/**/*.rb" }
rescue LoadError
  $stderr.puts "please install big_band"
end

begin
  require "yard"
  require "big_band/integration/yard"
  YARD::Rake::YardocTask.new("doc") do |t|
    t.options = %w[--main README.rdoc --backtrace]
  end
rescue LoadError
  $stderr.puts "please install big_band and yard"
end
  
task :default => :spec
