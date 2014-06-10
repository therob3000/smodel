require 'sinatra'
require 'tesla-api'

set :server, 'webrick'
enable :sessions

get "/" do
  if valid_login?
    redirect to("/status")
  else
    erb :index
  end
end

get "/logout" do
  if valid_login?
    session[:username] = nil
    session[:password] = nil
    redirect to("/")
  end
end

get "/status" do
  if valid_login?
    begin
      vehicle = TeslaAPI::Connection.new(session[:username], session[:password]).vehicle
      status_hash = {}
      status_hash['charge_state'] = vehicle.charge_state
      status_hash['vehicle_state'] = vehicle.state
      require 'pry'; binding.pry
      status_hash['climate_state'] = vehicle.climate_state
      status_hash['drive_state'] = vehicle.drive_state
      erb :status, :locals => {:status_hash => status_hash}
    rescue TeslaAPI::Errors::InvalidResponse => e
      title = "#{e.response.http_header.status_code} #{e.response.http_header.reason_phrase}"
      message = "#{e.response.body}"
      erb :error, :locals => {:title => title, :message => message}
    rescue Exception => e
      require 'pry'; binding.pry
      title = "Unhandled exception"
      message = "#{e.to_s}"
      erb :error, :locals => {:title => title, :message => message}
    end
  else
    redirect to("/")
  end
end

post "/login" do
  begin
    connection = TeslaAPI::Connection.new(params[:username], params[:password])
    if connection.logged_in?
      session[:username] = params[:username]
      session[:password] = params[:password]
      redirect to("/status")
    else
      # TODO: Need much better error handling.
      raise "Wrong username or password."
    end
  rescue
    erb :error, :locals => {:title => "Login failed", :message => "Could not log in to the Tesla API."}
  end
end

def valid_login?
  session[:username] && session[:password]
end
