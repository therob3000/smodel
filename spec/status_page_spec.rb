
ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'rspec'

describe "StatusPage" do
  include Capybara::DSL

  before(:all) do
    Capybara.app = Sinatra::Application.new
  end

  context "when asking for charge state" do
  use_vcr_cassette('connection', :record => :none)
    it "should display the charge percentage" do
      visit '/'
      fill_in :username, :with => 'user@example.com'
      fill_in :password, :with => 'password'
      click_button 'Submit'
      print page.html
    end
  end
end
