require 'rake/testtask'
require 'fileutils'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'lib/heroku_tasks'

task :default => ['test']

GEM_NAME = "danmayer-resume"

desc "run sintra server locally"
task :run do
  exec "ruby resume.rb"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = GEM_NAME
    gemspec.summary = "Resume gem"
    gemspec.description = "A gem for Dan Mayer's resume"
    gemspec.email = "dan@mayerdan.com"
    gemspec.homepage = "http://github.com/danmayer/Resume"
    gemspec.authors = ["Dan Mayer"]
    gemspec.executables = [GEM_NAME]
    gemspec.add_development_dependency "jeweler"
    gemspec.add_dependency "main"
    gemspec.add_dependency "maruku"
    gemspec.add_dependency "sinatra", '~> 1.0'
    gemspec.add_dependency "erubis"
    gemspec.add_dependency 'less'
    gemspec.add_dependency 'launchy'
    gemspec.add_dependency 'rdiscount'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

namespace :db do
  desc "migrate the DB"
  task :migrate do
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/fitbit.db")
    DataMapper.auto_migrate!
  end
end


desc "run all tests"
task :test do
  Rake::Task['test:rack'].invoke
  Rake::Task['test:unit'].invoke
end

namespace :test do
  desc "run rack tests"
  Rake::TestTask.new(:rack) do |t|
    t.libs << "test"
    t.pattern = "test/rack/**/*_test.rb"
    t.verbose = true
  end

  desc "run unit tests"
  Rake::TestTask.new(:unit) do |t|
    t.libs << "test"
    t.pattern = "test/unit/**/*_test.rb"
    t.verbose = true
  end
end

# hard to interact iwth sinatra straight from rake, or at least I can't seem to find how.
# desc "render phonegap index page"
# task :render_for_phonegap do
#   require File.join(File.dirname(__FILE__), 'fitbit-widget.rb')
#   require 'erb'

#   template = ERB.new('views/index.erb')
#   content = erb :index
#   local_filename tmp/index.html
#   File.open(local_filename, 'w') {|f| f.write(content) }
# end
