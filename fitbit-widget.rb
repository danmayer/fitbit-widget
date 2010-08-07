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
require 'do_postgres'
require 'ostruct'  
require 'erb'
require 'chronic'
require 'logger'

class Account
  include DataMapper::Resource

  property :id,    String, :key => true
  property :token, String,
  :length => 64, 
  :default => lambda {|resource, property|
    digest = Digest::SHA2.new 
    digest << resource.id.to_s << Time.now.to_s << rand.to_s
    digest.to_s
  }
  property :fitbit_email,      String
  property :fitbit_pass,      String

  def complete?
    fitbit_email && fitbit_pass
  end
end

configure :production do
  CALLBACK_URI_PREFIX = "https://"
  DataMapper::setup(:default, ENV['DATABASE_URL'])
  #DataMapper.auto_migrate!
  DataMapper.auto_upgrade!

  # before do
  #     unless (@env['HTTP_X_FORWARDED_PROTO'] || @env['rack.url_scheme'])=='https'
  #       redirect "https://#{request.env['HTTP_HOST']}#{request.env["REQUEST_PATH"]}"
  #     end
  #   end
  require 'rack-ssl-enforcer'
  use Rack::SslEnforcer
end

configure :development do
  CALLBACK_URI_PREFIX = "http://"
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/fitbit.db")
  # DataMapper.auto_migrate!
  DataMapper.auto_upgrade!
  #require 'rack/perftools_profiler'
  #use Rack::PerftoolsProfiler, :default_printer => 'gif'
end

set :views, File.dirname(__FILE__) + '/views'

use Rack::Session::Cookie, :key => 'fitbit.session',
                           #:domain => 'fitbit.heroku.com',
                           #:path => '/',
                           :expire_after => (60*60*24*30), # In seconds
                           :secret => 'ILoveBatmanSoDoYou'

# helpers
def open_id_auth_uri
  encoded_callback_uri = URI.escape("#{CALLBACK_URI_PREFIX}#{request.env['HTTP_HOST']}/id_callback")
  "#{CALLBACK_URI_PREFIX}fitbit-widget.rpxnow.com/openid/embed?token_url=#{encoded_callback_uri}"
end

def account_complete?(account)
  account!=nil && account.complete?
end

def format_date(date)
  date.strftime("%Y-%m-%d")
end

def short_date_span(start_date, end_date)
  "#{end_date.strftime("%m/%d")} - #{start_date.strftime("%m/%d")}"
end

#TODO man this needs to be cleaned up, caching, repeated code, object creation
def get_account_data(account, start_date = nil, end_date = nil)
  start_date ||= Chronic.parse('1 day ago')
  end_date ||= Chronic.parse('8 days ago')

  #TODO move to cache method
  cache_path = "tmp/#{account.fitbit_email}-#{format_date(start_date)}.json"
  data = if File.exists?(cache_path)
           JSON.parse(File.read(cache_path))
         else
           @fitbit = RubyFitbit.new(account.fitbit_email,account.fitbit_pass)
           data = @fitbit.get_avg_data(start_date, end_date) 
           #for faster debugging
           #data = {'steps' => 0.22, 'calories' => 0.22, 'miles_walked' => 0.22}
           File.open(cache_path, 'w') {|f| f.write(data.to_json) }
           data
         end
  
  cache_path = "tmp/#{account.fitbit_email}-aggregate-#{format_date(start_date)}.json"
  aggregate_data = if File.exists?(cache_path)
                     JSON.parse(File.read(cache_path))
                   else
                     @fitbit = RubyFitbit.new(account.fitbit_email,account.fitbit_pass) unless @fitbit
                     aggregate_data = @fitbit.get_aggregated_data(start_date, end_date) 
                     File.open(cache_path, 'w') {|f| f.write(aggregate_data.to_json) }
                     aggregate_data
                   end
  
  @avg_steps = '%.2f' % data['steps'].to_f
  @avg_calories = '%.2f' % data['calories'].to_f
  @avg_miles = '%.2f' % data['miles_walked'].to_f
  
  @aggregate_data = aggregate_data
  @aggregate_data = {} unless @aggregate_data
  @recent_data = @aggregate_data.sort.last.last
end

# actions
get '/' do
  puts('hit fontpage')
  if session["id"]
    redirect '/home'
  else
    erb :index, :layout => !request.xhr?
  end
end

get '/logout' do
  session["id"] = nil
  redirect '/'
end

get '/home' do
  if session["id"]
    @account = Account.get(session["id"])
    if account_complete?(@account)
      @navigate = true
      @start_date = if params[:previous]
                      Chronic.parse('yesterday', :now => Chronic.parse(params[:previous]))
                    elsif params[:next]
                      Chronic.parse('tomorrow', :now => Chronic.parse(params[:next]))
                    else
                      Time.now
                    end
      @end_date = Chronic.parse('7 days ago', :now => @start_date)
      get_account_data(@account, @start_date, @end_date)
      output = erb :home
    else
      redirect '/account'
    end
  else
    redirect '/account'
  end
end

get '/account' do
  if session["id"]
    @account = Account.get(session["id"])
    output = erb :account
  else
    output = erb :account_login
  end
  output
end

get '/get_widget' do
  if session["id"]
    @account = Account.get(session["id"])
    erb :get_widget
  else
    redirect '/account'
  end
end

post '/account/edit' do
  account = Account.get(session["id"])
  account.fitbit_email = params['email']
  account.fitbit_pass = params['password']
  account.save!
  redirect '/account'
end

post '/account/login' do
  identifier = (params['email']+"fitbit"+params['password']).hash
  account = Account.get(identifier) 
  account ||= Account.new(:id => identifier)
  session["id"] ||= identifier
  account.fitbit_email = params['email']
  account.fitbit_pass = params['password']
  account.save!
  if account_complete?(account)
    redirect '/home'
  else
    redirect '/account'
  end
end

post '/id_callback' do
    url = URI.parse('https://rpxnow.com/api/v2/auth_info')
    req = Net::HTTP::Post.new(url.path)
    rpx_key = ENV['rpx_key']
    req.set_form_data({'token' => params[:token],
                        'apiKey' => rpx_key, 
                        'format' => 'json'})
    
    http = Net::HTTP.new(url.host,url.port)
    http.use_ssl = true if url.scheme == 'https'
    resp = http.request(req)

    json = JSON.parse(resp.body)
    
    if json['stat'] == 'ok'
      profile           = json['profile']
      unique_identifier = profile['identifier']
      nickname          = profile['preferredUsername']
      nickname          = profile['displayName'] if nickname.nil?
      email             = profile['email']
      
      account = Account.get(unique_identifier) 
      account ||= Account.new(:id => unique_identifier)
      account.save!
      session["id"] ||= unique_identifier
      if account_complete?(account)
        redirect '/home'
      else
        redirect '/account'
      end
    else
      # flash[:notice] = 'Log in failed'
      redirect '/'
    end
end

#TODO move to production only 24 hr varnish HTTP cache
get %r{^/widget/(.*)} do |id|
  account = Account.get(:token => id)
  #default to the example account (mine, to show an example)
  account ||= OpenStruct.new(:fitbit_email => ENV['fitbit_email'], :fitbit_pass => ENV['fitbit_pass'])

  begin
    get_account_data(account)

    erb :widget, :layout => false
  rescue NoMethodError, SocketError => error
    puts error
    'Fitbit account information not correct or temporary account retreival error.'
  end
end

# the below methods are just a feature Idea I am testing, not in prod
get '/backup' do
  account = Account.get(session["id"])
  erb :backup
end

get '/backup_simple' do
  account = Account.get(session["id"])
  output = erb :backup_simple
end

get '/backup_data' do
  account = Account.get(session["id"])

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
  account = Account.get(session["id"])

  start_date = Chronic.parse('1 day ago')
  end_date = Chronic.parse('8 days ago')

  # @fitbit = RubyFitbit.new(account.fitbit_email,account.fitbit_pass)
  # data = @fitbit.get_aggregated_data(start_date, end_date) 
  {'steps' => 0.22, 'calories' => 0.22, 'miles_walked' => 0.22}.to_json
end
