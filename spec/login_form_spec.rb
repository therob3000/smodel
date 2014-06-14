ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'rspec'

describe "LoginPage" do
  include Capybara::DSL

  before(:all) do
    Capybara.app = Sinatra::Application.new
  end

  it "should prompt for logging in" do
    visit '/'
    expect(page).to have_content "Login"
    expect(page).to have_content "Password"
  end

  context "with a stubbed connection", :vcr => {:cassette_name => "connection_and_status_not_charging", :record => :none} do
    it "should accept our test login and redirect to /status" do
      log_me_in
      expect(current_path).to eq "/status"
      expect(page).to have_content "Status"
    end
  end

end
