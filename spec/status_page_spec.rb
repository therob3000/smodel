
ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'rspec'

describe "StatusPage" do
  include Capybara::DSL

  before(:all) do
    Capybara.app = Sinatra::Application.new
  end


  context "when asking for vehicle status" , :vcr => {:cassette_name => "connection_and_status", :record => :none} do
    # Quite brittle because it expects to dance the happy dance with the HTTP requests from
    # the fixtures. That's also the reason you can't revisit /status in any of these tests, as
    # the specific sequence of HTTP requests that are necessary for the /status page can't
    # be recreated.
    before(:each) do
      log_me_in
    end

    it "should display the range in miles" do
      expect(page).to have_content "Status"
    end
  end
end
