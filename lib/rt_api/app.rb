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

require 'grape'
require 'rt_api'
require 'rt_api/models'
require 'rt_api/cli'
require 'rt_api/ticket_creator'
require 'rt_api/config'

module RTAPI
  class App < Grape::API
    use Rack::Runtime
    use Rack::CommonLogger

    format :json

    http_basic(realm: 'json RT-API') do |user, pass|
      [user, pass] == ['rt-api', 'secret_password']
    end

    helpers do
      def config
        RTAPI::Config.load
      end

      def cli
        RTAPI::CLI.new(config)
      end

      def ticket_creator
        RTAPI::TicketCreator.new(cli, config)
      end
    end

    resources :icinga do
      desc 'Creates a ticket from a service notification'
      params do
        requires :problem_id
        requires :last_problem_id
        requires :hostname
        requires :state
        requires :state_type
        requires :description
        requires :output
      end
      post :service_notification do
        ticket_creator.create(RTAPI::ServiceNotification.new(params))
      end

      desc 'Creates a ticket from a host notification'
      params do
        requires :problem_id
        requires :last_problem_id
        requires :hostname
        requires :state
        requires :state_type
        requires :output
      end
      post :host_notification do
        ticket_creator.create(RTAPI::HostNotification.new(params))
      end
    end

    resources :health do
      desc 'returns a health status code'
      get :status do
        {status: "OK"}
      end
    end
  end
end
