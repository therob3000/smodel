require 'smodel'
require 'rack/test'

class CapybaraTest < Test::Unit::TestCase
  include Capybara::DSL
  def setup
    Capybara.app = Sinatra::Application.new
  end
end
