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
