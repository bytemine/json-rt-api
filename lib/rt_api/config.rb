require 'virtus'
require 'pathname'
require 'yaml'

module RTAPI
  class Config
    include Virtus.model

    PATHS = [
      Pathname.new('/etc/json-rt-api.yml'),
      Pathname.new('./config.yml').expand_path
    ]

    class Path < Virtus::Attribute
      def coerce(value)
        Pathname.new(value)
      end
    end

    attribute :bin, Path
    attribute :url, String
    attribute :default_queue, String
    attribute :username, String
    attribute :password, String
    attribute :host, String
    attribute :port, Integer
    attribute :queues, Hash
    attribute :autoresolve, Boolean

    def self.load
      path = PATHS.find {|p| p.exist? }

      new(YAML.load_file(path))
    rescue => e
      RTAPI.log.error("Unable to load config: #{e.message}")
    end
  end
end
