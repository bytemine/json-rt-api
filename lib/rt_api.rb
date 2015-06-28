require 'logger'

module RTAPI
  VERSION = '0.9.5'

  @logger = ::Logger.new(STDOUT)

  def self.logger(logger = nil)
    @logger = logger if logger
    @logger
  end

  def self.log
    @logger
  end
end
