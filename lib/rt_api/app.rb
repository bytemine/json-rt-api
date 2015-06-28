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
