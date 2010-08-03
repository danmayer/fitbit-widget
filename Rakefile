require 'rake/testtask'
require 'fileutils'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'do_postgres'

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

desc "render github index page, which can be displayed at user.github.com"
task :render_for_github do	
    require File.join(File.dirname(__FILE__), 'lib', 'resume_gem')
    resume = Resume.new('data/resume.yml')
    resume.write_html_and_css_to_disk('./')
end

namespace :heroku do

  desc "create a heroku project for you site"
  task :create do
    unless ENV.include?("name")	
      raise "usage: rake heroku:create name=PROJECT_NAME # example danmayer-resume\n" 
    end
    project_name = ENV['name']
    puts "creating heroku project #{project_name}"
    puts `heroku create #{project_name}`
    puts `git remote add heroku-production git@heroku.com:#{project_name}.git`
  end

  #todo make the first create, build the staging env by default
  desc "create a heroku project for your resume"
  task :create_staging do
    unless ENV.include?("name")	
      raise "usage: rake heroku:create_staging name=PROJECT_NAME # example danmayer-resume\n" 
    end
    project_name = "#{ENV['name']}-staging"
    puts "creating heroku project #{project_name}"
    puts `heroku create #{project_name}`
    puts `git remote add heroku-staging git@heroku.com:#{project_name}.git`
  end

end

namespace :deploy do
  desc "Deploy production to Heroku."
  task :production do
    `git push heroku-production master`
  end

  desc "Deploy staging to Heroku."
  task :staging do
    `git push heroku-staging master`
  end
end

namespace :github do
  desc "render github index page, which can be displayed at user.github.com"
  task :render_pages do	
    require File.join(File.dirname(__FILE__), 'lib', 'resume_gem')
    resume = Resume.new('resume.yml')
    puts "writing resume github index files to disk"
    resume.write_html_and_css_to_disk('./')
  end
end
