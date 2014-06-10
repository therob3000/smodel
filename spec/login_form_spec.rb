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

  context "with a stubbed connection" do
  use_vcr_cassette("connection_and_status", :record => :none)
    it "should accept our bogus test login and redirect to /status" do
      visit '/'
      fill_in :username, :with => 'user@example.com'
      fill_in :password, :with => 'password'
      click_button 'Submit'
      expect(current_path).to eq "/status"
      expect(page).to have_content "Status"
    end
  end

end
