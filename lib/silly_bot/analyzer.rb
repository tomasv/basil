require "silly_bot/profile"

module SillyBot
  class Analyzer
    def initialize(message)
      @message = message
      @user = message.from
      @phrase = message.text
      @words = @phrase.split
      @frequencies = frequencies(@words)
    end

    def analyze
      Profile.new name: @user,
                  frequencies: @frequencies,
                  phrase: @phrase
    end

    private

    def frequencies(words)
      frequencies = Hash.new(0)
      words.each do |word|
        frequencies[word] += 1
      end
      frequencies
    end
  end
end
