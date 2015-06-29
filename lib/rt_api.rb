# Written by / Copyright (C) 2015 bytemine GmbH
# 2-Clause BSD License applies. See LICENSE.

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
