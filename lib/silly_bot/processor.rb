require 'silly_bot/store'
require 'silly_bot/analyzer'

module SillyBot
  class Processor
    def initialize(message, store=SillyBot::Store.instance)
      @message = message
      @store = store
    end

    def process
      result = Analyzer.new(@message).analyze
      @store.save(result)
    end
  end
end
