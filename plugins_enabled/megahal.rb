# encoding: UTF-8

require 'megahal'

Basil.watch_for(/(.*)/) {
  question = @match_data[1]
  response = Megahal::Client.new.ask question
  nil
}

Basil.respond_to(/pasakyk (.*)/) {
  question = @match_data[1]
  response = Megahal::Client.new.ask question
  replies response
}
