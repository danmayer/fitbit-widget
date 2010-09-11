def get_local_resource(url)
  if @root_url
    url.gsub(/^\//,'')
  else
    url
  end
end

def get_url(url)
  if @root_url
    "#{@root_url}#{url}"
  else
    url
  end
end

def is_app?
  !@root_url.nil?
end


def format_date(date)
  date.strftime("%Y-%m-%d")
end

def short_date_span(start_date, end_date)
  "#{end_date.strftime("%m/%d")} - #{start_date.strftime("%m/%d")}"
end

def render_home
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
  erb :home, :layout => (request.xhr? ? :partial_layout : :layout)
end

#TODO man this needs to be cleaned up, caching, repeated code, object creation
def get_account_data(account, start_date = nil, end_date = nil)
  start_date ||= Chronic.parse('1 day ago')
  end_date ||= Chronic.parse('8 days ago')

  #TODO move to cache method
  FileUtils.mkdir('tmp/') unless File.exists?('tmp/')
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
