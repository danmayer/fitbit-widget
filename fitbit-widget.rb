#!/usr/bin/ruby1.8
require 'rubygems'
require 'sinatra'
require 'ruby-fitbit'
require 'json'
require 'net/http'
require 'net/https'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'ostruct'  
require 'erb'
require 'chronic'
require 'logger'
require 'fileutils'
require 'lib/helpers'
require 'lib/sinatra_simple_account'

configure :production do
  CALLBACK_URI_PREFIX = "https://"
  require 'do_postgres'
  DataMapper::setup(:default, ENV['DATABASE_URL'])
  #DataMapper.auto_migrate!
  DataMapper.auto_upgrade!

  #force all traffic over https
  require 'rack-ssl-enforcer'
  use Rack::SslEnforcer
end

configure :development do
  CALLBACK_URI_PREFIX = "http://"
  begin
    require 'sqlite3'
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/fitbit.db")
  rescue LoadError
    require 'do_mysql'
    DataMapper::setup(:default, {
                                 :adapter  => 'mysql',
                                 :host     => 'localhost',
                                 :username => 'root',
                                 :password => '',
                                 :database => 'fitbit_widget_development'
                               })
  end
  # DataMapper.auto_migrate!
  DataMapper.auto_upgrade!

  #For debugging performance
  #require 'rack/perftools_profiler'
  #use Rack::PerftoolsProfiler, :default_printer => 'gif'
end

set :views, File.dirname(__FILE__) + '/views'

use Rack::Session::Cookie, :key => 'fitbit.session',
                           #:domain => 'fitbit.heroku.com',
                           #:path => '/',
                           :expire_after => (60*60*24*30), # In seconds
                           :secret => 'ILoveBatmanSoDoYou'

include SinatraSimpleAccount

before do
  #set account if it is found
  identifier = if(params['email'] && params['password'] && params['email']!='' && params['password']!='')
                 (params['email']+"fitbit"+params['password']).hash
               elsif session["id"]
                 session["id"]
               end
  @account = Account.get(identifier) 
  if @account==nil && (params['email'] && params['password']) && params['email']!='' && params['password']!=''
    @account = Account.new(:id => identifier)
    @account.fitbit_email = params['email']
    @account.fitbit_pass = params['password']
    @account.save!
  end
end

# actions
get '/' do
  if session["id"]
    if @account && account_complete?(@account)
      render_home
    else
      render_account
    end
  else
    erb :index, :layout => (request.xhr? ? :partial_layout : :layout)
  end
end

get '/home' do
  if @account && account_complete?(@account)
    render_home
  else
    redirect '/account'
  end
end

get '/get_widget' do
  if @account
    erb :get_widget, :layout => (request.xhr? ? :partial_layout : :layout)
  else
    redirect '/account'
  end
end

#TODO move to production only 24 hr varnish HTTP cache
get %r{^/widget/(.*)} do |id|
  account = Account.get(:token => id)
  #default to the example account (mine, to show an example)
  account ||= OpenStruct.new(:fitbit_email => ENV['fitbit_email'], :fitbit_pass => ENV['fitbit_pass'])

  get_account_data(account)

  if @error_msg
    'Fitbit account information not correct or temporary account retreival error.'
  else
    erb :widget, :layout => false
  end
end

get '/food_complete' do
  fitbit = RubyFitbit.new(@account.fitbit_email, @account.fitbit_pass)
  complete = fitbit.get_food_items(params['q'])
  complete = complete.map{|food| food['name']}.uniq.reverse[0..10]
  complete.join("\r\n")
end

post '/log_food' do
  if @account
    food = params['food']
    quantity = params['quantity']
    quantity_type = params['quantity_type']
    quantity = "#{quantity} #{quantity_type}"
    meal_type = params['meal_type']
    food_date = if params['food_date']
                  Time.parse(params['food_date'])
                else
                  Time.now
                end

    begin
      fitbit = RubyFitbit.new(@account.fitbit_email, @account.fitbit_pass)
      fitbit.submit_food_log({:food => food, :unit => quantity, :meal_type => meal_type, :date => food_date})
    rescue => error
      puts error
      error_msg = "Sorry either the food can't be found or the quantity type is invalid for this type of food. Try again!"
      session[:error_msg] = error_msg
    end
    if request.xhr?
      render_home
    else
      redirect '/home'
    end
  else
    redirect '/account'
  end
end

###
# currently the easiest way to generate the phonegap app is visit
# this action. It should be a rake task, but setting up the ENV in rake
# to render views in sinatra kinda sucks.
###
get '/write_index' do
  @hide_example = true
  @root_url = "https://fitbit-widget.heroku.com"
  content = erb :index
  local_filename = 'phonegap-android/assets/www/index.html'
  File.open(local_filename, 'w') {|f| f.write(content) }

  FileUtils.cp_r 'public/.', 'phonegap-android/assets/www'

  # alter the CSS as needed
  css_file = "phonegap-android/assets/www/base.css"
  content = File.read(css_file)
  content = content.gsub(/url\(\//,'url(')
  File.open(css_file, 'w') {|f| f.write(content) }
  "wrote index, and copied assests to phonegap"
end

######
# the below methods are just a feature Idea I am testing, not in prod
######
get '/backup' do
  erb :backup
end

get '/backup_simple' do
  output = erb :backup_simple
end

get '/backup_data' do
  start_date = Chronic.parse('1 day ago')
  end_date = Chronic.parse('8 days ago')

  # @fitbit = RubyFitbit.new(account.fitbit_email,account.fitbit_pass)
  # data = @fitbit.get_aggregated_data(start_date, end_date) 
  output = <<-"EOF"
<ul>
  <li>'steps' => 0.22</li>
  <li>'calories' => 0.22</li>
  <li>'miles_walked' => 0.22</li>
</ul>
EOF
end

get '/backup_data.json' do
  start_date = Chronic.parse('1 day ago')
  end_date = Chronic.parse('8 days ago')

  # @fitbit = RubyFitbit.new(account.fitbit_email,account.fitbit_pass)
  # data = @fitbit.get_aggregated_data(start_date, end_date) 
  {'steps' => 0.22, 'calories' => 0.22, 'miles_walked' => 0.22}.to_json
end
