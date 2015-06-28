require 'pathname'
require 'systemu'

module RTAPI
  class CLI
    class SearchResponse
      attr_reader :ticket_subject

      def initialize(response)
        @response = response
        @ticket_id, @ticket_subject = response.split(': ', 2)
      end

      def ticket_id
        @ticket_id.to_i
      end

      def exist?
        !@ticket_id.nil? && !@ticket_subject.nil?
      end

      def message
        @response
      end
    end

    class CreateResponse
      attr_reader :ticket_id

      def initialize(response)
        @response = response

        if response =~ /^# Ticket (\d+) created/
          @ticket_id = $1
        elsif response =~ /^# Ticket (\d+) updated/
          @ticket_id = $1
        end
      end

      def message
        @response
      end

      def success?
        !!ticket_id
      end
    end

    class CommentResponse
      attr_reader :success

      def initialize(response)
        @response = response
        @success = false

        if response =~ /^# Message recorded/
          @success = true
        end
      end

      def success?
        @success
      end

      def message
        @response
      end
    end

    class ShowResponse
      attr_reader :owner

      def initialize(response)
        @response = response
        @owner = response.split(': ', 2)[1]
      end

      def unowned?
        @owner.start_with?("Nobody")
      end

      def message
        @response
      end
    end

    ShelloutError = Class.new(StandardError)

    def initialize(config)
      @config = config
      @cli = @config.bin.expand_path

      raise ArgumentError, "RT command #{@cli} does not exist" unless @cli.exist?
    end

    def find_ticket(notification)
      subject_id = notification.subject_id

      ret = rt(%(list -s "Subject LIKE '#{subject_id}' AND Status != 'resolved'" -q #{queue_name(notification)}))
      SearchResponse.new(ret)
    end

    def ticket_unowned?(response)
      ticket_id = response.ticket_id

      ret = rt(%(show ticket/#{ticket_id} -f owner,id))
      # Owner: Nobody
      # id: ticket/18578
      ShowResponse.new(ret).unowned?
    end

    def create_ticket(notification)
      subject = notification.subject
      text = notification.text

      ret = rt(%(create -t ticket set subject="#{subject}" queue="#{queue_name(notification)}" text="#{text}"))
      CreateResponse.new(ret)
    end

    def comment_ticket(response, notification)
      ticket_id = response.ticket_id

      # RT CLI does not allow linebreaks in message
      ret = rt(%(comment -m "State: #{notification.state} +++ Output: #{notification.output}" #{ticket_id}))
      CommentResponse.new(ret)
    end

    def resolve_ticket(response, notification)
      ticket_id = response.ticket_id

      ret = rt(%(edit #{ticket_id} set status=deleted))
      CreateResponse.new(ret)
    end

    private

    def queue_name(notification)
      @config.queues.keys.each do |key|
        return @config.queues[key] if notification.hostname.index(key)
      end
      @config.default_queue
    end

    def rt(cmd)
      RTAPI.log.info("Executing command: #{@cli} #{cmd}")

      with_rt_env do
        status, stdout, stderr = systemu("#{@cli} #{cmd}")

        if status.success?
          stdout.chomp
        else
          raise ShelloutError, "Command '#{cmd}' failed with: #{stderr.chomp}"
        end
      end
    end

    def with_rt_env
      old_env = ENV.dup

      ENV['RTUSER'] = @config.username
      ENV['RTPASSWD'] = @config.password
      ENV['RTSERVER'] = @config.url

      yield
    ensure
      ENV.replace(old_env)
    end
  end
end
