# Copyright (c) 2015, bytemine GmbH
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation and/or 
# other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
# OF THE POSSIBILITY OF SUCH DAMAGE.


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
