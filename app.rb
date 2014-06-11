require 'sinatra'
require 'tesla-api'

set :server, 'webrick'
enable :sessions

get "/" do
  if valid_login?
    redirect to("/status")
  else
    erb :login
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
      status_hash['charge_state'] = charge_state_to_hash(vehicle.charge_state)
      status_hash['vehicle_state'] = {:foo => 'bar'}
      status_hash['climate_state'] = {:foo => 'bar'}
      status_hash['drive_state'] = {:foo => 'bar'}
      #require 'pry'; binding.pry
      #status_hash['vehicle_state'] = vehicle_state_to_hash(vehicle.state)
      #status_hash['climate_state'] = climate_state_to_hash(vehicle.climate_state)
      #status_hash['drive_state'] = drive_state_to_hash(vehicle.drive_state)
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

# Converts a state (as represented by TeslaAPI) into a hash of
# simple values e.g. for display on the status page.
# We can't allow the status page direct access to the TeslaAPI object.
def charge_state_to_hash(state)
  #@charging_state=Disconnected @charging_to_max=false @battery_range_miles=177.38 @estimated_battry_range_miles=143.96 @ideal_battery_range_miles=204.15 @battery_percentage=70 @battery_current_flow=-0.2 @charger_voltage=0 @charger_pilot_amperage=0 @charger_actual_amperage=0 @charger_power=0 @hours_to_full_charge= @charge_rate_miles_per_hour=-1.0 @charge_port_open=false @supercharging=false @charging=false @charge_complete=false
  hash = {}
  hash['charging_state'] = state.charging_state
  hash['battery_range_miles'] = state.battery_range_miles
  hash['estimated_battery_range_miles'] = state.estimated_battery_range_miles
  hash['ideal_battery_range_miles'] = state.ideal_battery_range_miles
  hash
  # WIP
end
