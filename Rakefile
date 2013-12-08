require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "hierarchy"
  gem.summary = %Q{Use PostgreSQL LTREE type with ActiveRecord}
  gem.description = %Q{Adds ActiveRecord support for hierarchical data structures using PostgreSQL's LTREE column type.}
  gem.email = "git@timothymorgan.info"
  gem.homepage = "http://github.com/riscfuture/hierarchy"
  gem.authors = [ "Tim Morgan" ]
  gem.required_ruby_version = '>= 1.9'
  gem.files = %w( lib/**/* templates/**/* LICENSE README.md hierarchy.gemspec )
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'yard'

# bring sexy back (sexy == tables)
module YARD::Templates::Helpers::HtmlHelper
  def html_markup_markdown(text)
    markup_class(:markdown).new(text, :gh_blockcode, :fenced_code, :autolink, :tables, :no_intraemphasis).to_html
  end
end

YARD::Rake::YardocTask.new('doc') do |doc|
  doc.options << '-m' << 'markdown'
  doc.options << '-M' << 'redcarpet'
  doc.options << '--protected' << '--no-private'
  doc.options << '-r' << 'README.md'
  doc.options << '-o' << 'doc'
  doc.options << '--title' << 'Hierarchy Documentation'

  doc.files = %w(lib/**/* README.md)
end

task(default: :spec)
