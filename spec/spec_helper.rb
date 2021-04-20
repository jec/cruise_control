# frozen_string_literal: true

Bundler.require(:test, :dev)

require "pry"
require "state_machines"
require_relative "../lib/cruise_control"
require_relative "../lib/vehicle"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before :suite do
    FactoryBot.find_definitions
  end
end
