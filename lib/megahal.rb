# encoding: UTF-8

module Megahal
  require 'pty'
  require 'expect'
  require 'logger'
  require 'singleton'

  @@logger = Logger.new('log/megahal.log')
  def self.logger
    @@logger
  end

  class Daemon
    include Singleton

    def initialize
      Megahal.logger.info("starting megahal daemon")

      @r, @w, @pid = PTY.spawn('megahal')
      @r.expect prompt

      autosave
      Megahal.logger.info("initialization complete")
    end

    def interpret(command)
      Megahal.logger.info("interpreting: #{command}")
      response = nil
      case command 
      when /#save/
        save
      when /#quit/
        quit
      else
        response = ask command
      end
      Megahal.logger.info("interpretation of #{command}: #{response}")
      response
    end

    def ask(question)
      Megahal.logger.info "received question: #{question}"
      response = send_command question
      response = strip_prompt(response)
      Megahal.logger.info "responding with: #{response}"
      response
    end

    def save
      Megahal.logger.info "saving..."
      send_command "#save"
      Megahal.logger.info "saved successfully"
    end

    def quit
      # Megahal.logger.info "quitting..."
      # send_command "#quit", false
    rescue Exception => e
      Megahal.logger.warn "quitting failed: #{e.inspect}"
    end

    def autosave(every=60)
      @autosave ||= Thread.new do 
        Megahal.logger.info("starting autosave every #{every}")
        loop do
          sleep every
          save
        end
      end
    end

    private

    def send_command command, wait_for_response=true
      @w.puts command
      @w.puts

      response = nil
      if wait_for_response
        @r.expect prompt
        response = @r.expect(prompt).first
      end
      response
    rescue Exception => e
      p e
    end

    def prompt
      "> "
    end

    def strip_prompt(string)
      string.gsub(prompt, '')
    end
  end

  class Client
    def initialize
      @hal = Daemon.instance
    end

    def ask question
      @hal.interpret question
    end
  end
end
