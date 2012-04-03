require "silly_bot/version"

require "silly_bot/analyzer"
require "silly_bot/configuration"
require "silly_bot/processor"
require "silly_bot/profile"
require "silly_bot/store"

module SillyBot
  require 'logger'

  def self.logger
    SillyBot.configuration.logger
  end

  def self.logger=(logger)
    SillyBot.configuration.logger = logger
  end
end
