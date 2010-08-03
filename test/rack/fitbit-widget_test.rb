require 'fitbit-widget'
require 'test/unit'
require 'rack/test'
require 'mocha' #lookup and use mocha testing

set :environment, :test

class ResumeTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_displays_greeting
    get '/'
    assert last_response.ok?
    assert_match "simple way to view fitbit data.", last_response.body
  end

  def test_it_displays_login
    get '/'
    assert_match "Login", last_response.body
  end
  
  def test_displays_example_account__invalid_info_error
    ENV['fitbit_email'] = 'bad'
    ENV['fitbit_pass'] = 'info'
    get '/widget/example'
    assert last_response.ok?
    assert_match "Fitbit account information not correct or temporary account retreival error", last_response.body
  end

  def test_displays_example_account
    ENV['fitbit_email'] = 'dan@mayerdan.com'
    #where to get this info to run a valid test? or mock out the fitbit API call?
    ENV['fitbit_pass'] = '...'
    get '/widget/example'
    assert last_response.ok?
    assert_match "Calories Burned", last_response.body
  end

end
