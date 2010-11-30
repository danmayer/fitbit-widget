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

  desc "Deploy production to Heroku."
  task :production do
    `git push heroku-production master`
  end

  desc "Deploy staging to Heroku."
  task :staging do
    `git push heroku-staging master`
  end

end
