require 'rake'
begin
  require 'bundler'
rescue LoadError
  puts "Bundler is not installed; install with `gem install bundler`."
  exit 1
end

Bundler.require :default

Jeweler::Tasks.new do |gem|
  gem.name = "hierarchy"
  gem.summary = %Q{Use PostgreSQL LTREE type with ActiveRecord}
  gem.description = %Q{Adds ActiveRecord support for hierarchial data structures using PostgreSQL's LTREE column type.}
  gem.email = "git@timothymorgan.info"
  gem.homepage = "http://github.com/riscfuture/hierarchy"
  gem.authors = [ "Tim Morgan" ]
  gem.required_ruby_version = '>= 1.9'
  gem.add_dependency 'rails', '>= 3.0.2'
end
Jeweler::GemcutterTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

YARD::Rake::YardocTask.new('doc') do |doc|
  doc.options << "-m" << "textile"
  doc.options << "--protected"
  doc.options << "-r" << "README.textile"
  doc.options << "-o" << "doc"
  doc.options << "--title" << "Hierarchy Documentation".inspect
  
  doc.files = [ 'lib/**/*', 'README.textile' ]
end

task(default: :spec)
