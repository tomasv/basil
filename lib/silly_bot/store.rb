require "silly_bot/configuration"
require "silly_bot/profile"

module SillyBot
  class Store
    def self.instance
      @store ||= Store.new
    end

    def initialize
      with_storage do |store|
        store[:silly_bot] ||= {}
      end
    end

    def save(result)
      raise "Result has no name in it" if result.blank?
      with_storage do |store|
        record = store[:silly_bot][result.name]
        
        profile = Profile.new(record)
        profile.update_with(result)

        store[:silly_bot][result.name] = profile.marshal_dump
      end
    end

    def find(name)
      result = nil
      with_storage do |store|
        result = store[:silly_bot][name]
      end
      Profile.new(result)
    end

    def clear
      with_storage do |store|
        store[:silly_bot] = {}
      end
    end

    def inspect
      result = nil
      with_storage do |store|
        result = store[:silly_bot]
      end
      SillyBot.logger.info result.inspect
      result.inspect
    end

    private

    def with_storage &block
      SillyBot.configuration.storage.with_storage &block
    end
  end
end
