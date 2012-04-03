require 'ostruct'

module SillyBot
  class Profile < OpenStruct
    def initialize(*args)
      super
      self.frequencies ||= {}
      self.phrases ||= []
    end

    def update_with(result)
      self.name ||= result.name
      self.frequencies.merge!(result.frequencies) do |key, oldval, newval|
        oldval.to_i + newval.to_i
      end
      self.phrases << result.phrase
    end

    def to_pretty_string
      output = ""
      output << "#{name} has said #{phrases.size} phrases\n"
      output << "5 favorite words:\n"
      frequencies.to_a.sort_by { |i| i.last }.reverse.take(5).each do |word, frequency|
        output << "-- #{frequency} times: #{word}\n"
      end
      output
    end
  end
end
