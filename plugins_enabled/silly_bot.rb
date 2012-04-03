require 'silly_bot'
require 'logger'

SillyBot.configure do |config|
  config.storage = Basil::Storage
  config.logger = Logger.new('log/silly_bot.log')
end

Basil.respond_to(/forget everything/) {
  SillyBot::Store.instance.clear
  says "(drunk)"
}

Basil.respond_to(/tell me everything/) {
  says SillyBot::Store.instance.inspect
}

Basil.respond_to(/isvalyk (.*)/) {
  name = @match_data[1]
  SillyBot::Store.instance.send(:with_storage) do |store|
    user = store[:silly_bot][name]
    user[:phrases] = [] if user[:phrases] 
  end
  nil
}

Basil.watch_for(//) {
  SillyBot::Processor.new(@msg).process
  if rand < 0.1
    SillyBot::Store.instance.send(:with_storage) do |store|
      user_stats = store[:silly_bot].to_a.sample.last
      says user_stats.inspect
      phrases = user_stats[:phrases] || ['nenoriu']
      says phrases.inspect
      says phrases.sample
    end
  else
    nil
  end
}

Basil.respond_to(/tell me about (.*)/) {
  name = @match_data[1]
  profile = SillyBot::Store.instance.find(name)
  says profile.to_pretty_string
}
