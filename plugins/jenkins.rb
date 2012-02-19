module Basil
  module Jenkins
    class Api
      include Basil::Utils

      def initialize(path)
        # path must include the trailing slash
        @path = path.gsub(/[^\/]$/, '\&/')
        @json = nil
      end

      def method_missing(method, *args)
        key = method.to_s

        if json.has_key?(key)
          json[key]
        else
          super
        end
      end

      private

      def json
        unless @json
          options = symbolize_keys(Config.jenkins).merge(:path => @path + 'api/json')
          @json = get_json(options)
        end

        @json
      end
    end

    class EmailStrategy
      # Use the subject to determine the build and report a simple one
      # line message to the chat.
      def create_message(mail)
        case mail['Subject']
        when /jenkins build is back to normal : (\w+) #(\d+)/i
          msg = "(dance) #{$1} is back to normal"
        when /build failed in Jenkins: (\w+) #(\d+)/i
          build, job = $1, $2

          extended = get_extended_info(build, job)
          url      = "http://#{Basil::Config.jenkins['host']}/job/#{build}/#{job}/changes"

          msg = [ "(headbang) #{$1} failed!", extended, "Please see #{url}" ].join("\n")
        else
          $stderr.puts "discarding non-matching email (subject: #{mail['Subject']})"
          return nil
        end

        Basil::Message.new(nil, Basil::Config.me, Basil::Config.me, msg)
      end

      def send_to_chat?(topic)
        topic =~ /no more broken builds/i
      end

      private

      def get_extended_info(build,job)
        if status = Api.new("/job/#{build}/#{job}")
          failCount  = status.actions[4]["failCount"] rescue '?'

          committers = []
          status.changeSet['items'].each do |item|
            committers << item['user']
          end

          "#{failCount} failure(s). Commits made by #{committers.join(", ")}."
        end
      end
    end
  end
end

Basil.check_email(Basil::Jenkins::EmailStrategy.new)

Basil.respond_to(/^jenkins( (stable|failing))?$/) {

  begin
    status_line = lambda do |job|
      " * #{job['name']} #{job['color'] =~ /blue/ ? "is stable." : "is FAILING. See #{job['url']} for details."}"
    end

    status = Basil::Jenkins::Api.new('/')

    says do |out|
      case (@match_data[2].strip rescue nil)
      when 'stable'
        out << "Current stable jobs:"
        status.jobs.select { |job| job['color'] =~ /blue/ }.each { |job| out << status_line.call(job) }
      when 'failing'
        out << "Current failing jobs:"
        status.jobs.reject { |job| job['color'] =~ /blue/ }.each { |job| out << status_line.call(job) }
      else
        out << "Current jobs:"
        status.jobs.each { |job| out << status_line.call(job) }
      end
    end
  rescue Exception => ex
    $stderr.puts "jenkins error: #{ex}"
    says "There was an issue talking to jenkins."
  end

}.description = 'interacts with jenkins'

Basil.respond_to(/^jenkins (\w+)/) {

  begin
    job = Basil::Jenkins::Api.new("/job/#{@match_data[1].strip}")

    says("#{job.displayName} is #{job.color =~ /blue/ ? "stable" : "FAILING"}") do |out|
      job.healthReport.each do |line|
        out << line['description']
      end

      out << "See #{job.url} for details."
    end
  rescue Exception => ex
    $stderr.puts "jenkins error: #{ex}"
    says "Can't find info on #{@match_data[1]}"
  end

}.description = 'retrieves info on a specific jenkins job'

Basil.respond_to(/^who broke (.+?)\??$/) {

  begin
    job = Basil::Jenkins::Api.new("/job/#{@match_data[1].strip}")

    builds = job.builds.map { |b| b['number'].to_i }
    last_stable = job.lastStableBuild['number'].to_i rescue nil

    if last_stable && builds.first == last_stable
      return says "#{job.displayName} is not broken."
    end

    i = 0
    while Basil::Jenkins::Api.new("/job/#{job.name}/#{builds[i]}").building
      i += 1
    end

    test_report = Basil::Jenkins::Api.new("/job/#{job.name}/#{builds[i]}/testReport")

    says do |out|
      test_report.suites.each do |s|
        s['cases'].each do |c|
          if c['status'] != 'PASSED'
            next if c['name'] =~ /marked_as_flapping/

            name  = "#{c['className']}##{c['name']}"
            since = c['failedSince']

            out << "#{name} first broke in #{since}"

            begin
              breaker = Basil::Jenkins::Api.new("/job/#{job.name}/#{since}")

              breaker.changeSet['items'].each do |item|
                out << "    * r#{item['revision']} [#{item['user']}] - #{item['msg']}"
              end
            rescue
              out << "    ! no info on that build"
            end

            out << ""
          end
        end
      end
    end
  rescue Exception => ex
    $stderr.puts "jenkins error: #{ex}"
    says "Can't find info on #{@match_data[1]}"
  end

}.description = 'tells you what commits lead to the first broken build'
