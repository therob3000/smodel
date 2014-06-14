
ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'rspec'

describe "StatusPage" do
  include Capybara::DSL

  before(:all) do
    Capybara.app = Sinatra::Application.new
  end


  context "when the vehicle isn't charging" , :vcr => {:cassette_name => "connection_and_status_not_charging", :record => :none} do
    # Quite brittle because it expects to dance the happy dance with the HTTP requests from
    # the fixtures. That's also the reason you can't revisit /status in any of these tests, as
    # the specific sequence of HTTP requests that are necessary for the /status page can't
    # be recreated.
    before(:each) do
      log_me_in
    end

    it "should display the charging state" do
      expect(find("#charging_state").text).to eq "Disconnected"
    end

    it "should display the battery range in kilometers and miles" do
      expect(find("#battery_range").text).to eq "285.47 km (177.38 mi)"
    end

    it "should display the estimated battery range in kilometers and miles" do
      expect(find("#estimated_battery_range").text).to eq "231.68 km (143.96 mi)"
    end

    it "should display the ideal battery range in kilometers and miles" do
      expect(find("#ideal_battery_range").text).to eq "328.55 km (204.15 mi)"
    end

    it "should display the battery charge percentage" do
      expect(find("#battery_percentage").text).to eq "70% full"
    end

    it "should display hours to full charge only if the car is charging" do
      expect(find("#hours_to_full_charge").text).to eq "Not charging"
    end

  end
end

def value_from_label(label)
  return first("td.label", :text => label).find(:xpath, "..").first("td.data").text
end
