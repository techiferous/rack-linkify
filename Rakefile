require 'rake'
require 'rake/testtask'
require 'rubygems'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test Rack::Linkify'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name          = "rack-linkify"
    s.version       = "0.0.2"
    s.author        = "Wyatt Greene"
    s.email         = "techiferous@gmail.com"
    s.summary       = "Rack middleware that adds anchor tags to URLs in text."
    s.description   = %Q{
      Any URLs that occur in the text of the web page are automatically surrounded
      by an anchor tag.
    }
    s.add_dependency('rack-plastic', '>= 0.1.1')
    s.add_development_dependency('redgreen')
    s.require_path  = "lib"
    s.files         = []
    s.files         << "README"
    s.files         << "LICENSE"
    s.files         << "CHANGELOG"
    s.files         << "Rakefile"
    s.files         += Dir.glob("lib/**/*")
    s.files         += Dir.glob("test/**/*")
    s.homepage      = "http://github.com/techiferous/rack-linkify"
    s.requirements  << "none"
    s.has_rdoc      = false
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
