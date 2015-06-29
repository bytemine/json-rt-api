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

module RTAPI
  class Notification
    include Virtus.model

    attribute :problem_id, String
    attribute :last_problem_id, String
    attribute :hostname, String
    attribute :state, String
    attribute :state_type, String
    attribute :output, String

    def id
      problem_id == '0' ? last_problem_id : problem_id
    end

    def subject_id
      %([#{hostname}:#{id}])
    end

    def subject
      raise "#{self.class.name}#subject needs to be defined."
    end

    def text
      "Output: #{output}"
    end

    def ok_or_up?
      state == "OK" || state == "UP"
    end

    def to_s
      "#{self.class.name}: Problem ID=#{problem_id}, Last problem ID=#{last_problem_id}, Hostname=#{hostname}, State=#{state}, Statetype=#{state_type}, Output=#{output}"
    end
  end

  class ServiceNotification < Notification
    attribute :description, String

    def subject
      "#{subject_id} SERVICE #{description} on #{hostname} is #{state}"
    end
  end

  class HostNotification < Notification
    def subject
      "#{subject_id} HOST #{hostname} is #{state}"
    end
  end
end
