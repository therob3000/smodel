require 'sinatra'
require 'tesla-api'

set :server, 'thin'
enable :sessions

get "/" do
  if logged_in?
    redirect to("/status")
  else
    erb :index
  end
end

get "/logout" do
  session[:username] = nil
  session[:password] = nil
  redirect to("/")
end

get "/status" do
  if logged_in?
    begin
      vehicle = TeslaAPI::Connection.new(session[:username], session[:password]).vehicle
      status_hash = {}
      status_hash['charge_state'] = vehicle.charge_state
      status_hash['vehicle_state'] = vehicle.vehicle_state
      status_hash['climate_state'] = vehicle.climate_state
      status_hash['drive_state'] = vehicle.drive_state
      erb :status, :locals => {:status_hash => status_hash}
    rescue TeslaAPI::Errors::InvalidResponse => e
      title = "#{e.response.http_header.status_code} #{e.response.http_header.reason_phrase}"
      message = "#{e.response.body}"
      erb :error, :locals => {:title => title, :message => message}
    rescue Exception => e
      title = "Unhandled exception"
      message = "#{e.to_s}"
      erb :error, :locals => {:title => title, :message => message}
    end
  else
    redirect to("/")
  end
end

post "/login" do
  session[:username] = params[:username]
  session[:password] = params[:password]
  redirect to("/status")
end

def logged_in?
  session[:username] && session[:password]
end
