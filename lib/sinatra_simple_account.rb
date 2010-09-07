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
  property :fitbit_email,     String
  property :fitbit_pass,      String

  def complete?
    fitbit_email && fitbit_pass && !fitbit_email.blank? && !fitbit_pass.blank?
  end
end

module SinatraSimpleAccount

  #TODO if uri_prefix isn't found default to http or current request.protocal
  def open_id_auth_uri
    encoded_callback_uri = URI.escape("#{CALLBACK_URI_PREFIX}#{request.env['HTTP_HOST']}/id_callback")
    "#{CALLBACK_URI_PREFIX}fitbit-widget.rpxnow.com/openid/embed?token_url=#{encoded_callback_uri}"
  end

  def account_complete?(account)
    account!=nil && account.complete?
  end

  post '/account/edit' do
    @account.fitbit_email = params['email']
    @account.fitbit_pass = params['password']
    @account.save!
    redirect '/account'
  end

  post '/account/login' do
    redirect '/account' && return unless params['email'] && params['password']
    identifier = (params['email']+"fitbit"+params['password']).hash
    account = Account.get(identifier) 
    account ||= Account.new(:id => identifier)
    session["id"] ||= identifier
    account.fitbit_email = params['email']
    account.fitbit_pass = params['password']
    account.save!
    if account_complete?(account)
      if request.xhr?
        @account = account
        render_home
      else
        redirect '/home'
      end
    else
      session["id"] = nil
      if request.xhr?
        erb :account_login, :layout => :partial_layout
      else
        redirect '/account'
      end
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

  get '/account' do
    if @account
      erb :account, :layout => (request.xhr? ? :partial_layout : :layout)
    else
      erb :account_login, :layout => (request.xhr? ? :partial_layout : :layout)
    end
  end

  get '/logout' do
    session["id"] = nil
    if request.xhr?
      erb :index, :layout => :partial_layout
    else
      redirect '/'
    end
  end

end
