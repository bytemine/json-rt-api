module RTAPI
  class TicketCreator
    def initialize(cli, config)
      @cli = cli
      @config = config
    end

    def create(notification)
      RTAPI.log.info("+++ OUTPUT +++ #{notification.to_s}")

      response = @cli.find_ticket(notification)

      if response.exist?
        unless notification.problem_id == "0"
          # ticket already existing
          RTAPI.log.info("Ticket exists: #{response.ticket_id}")

          {success: true, message: "Ticket exists: #{response.ticket_id}"}
        else
          res_comment = @cli.comment_ticket(response, notification)
          if res_comment.success?
            RTAPI.log.info("Ticket #{response.ticket_id} commented")
          else
            RTAPI.log.info("Unable to comment ticket: #{res_comment.message}")
          end

          if @config.autoresolve?
            if @cli.ticket_unowned?(response)
              # resolve this ticket if
              # the autoresolve config is set, and
              # the ticket is unowned
              res_resolve = @cli.resolve_ticket(response, notification)

              if res_resolve.success?
                RTAPI.log.info("Ticket #{res_resolve.ticket_id} resolved")

                {success: true, message: "Ticket #{res_resolve.ticket_id} resolved"}
              else
                RTAPI.log.info("Unable to resolve ticket: #{res_resolve.message}")

                error!({success: false, message: "Unable to resolve ticket: #{res_resolve.message}"}, 400)
              end
            else
              RTAPI.log.info("Ticket #{response.ticket_id} has an owner, not closing it")
            end
          else
            RTAPI.log.info("Autoresolve is disabled, leaving ticket #{response.ticket_id} open")
          end
        end
      else
        # no ticket existing, create it
        unless notification.ok_or_up?
          # do not create a ticket if state is UP or OK
          res = @cli.create_ticket(notification)

          if res.success?
            RTAPI.log.info("Ticket #{res.ticket_id} created")

            {success: true, message: "Ticket #{res.ticket_id} created"}
          else
            RTAPI.log.info("Unable to create ticket: #{res.message}")

            error!({success: false, message: "Unable to create ticket: #{res.message}"}, 400)
          end
        else
          RTAPI.log.info("Monitoring state 'OK' or 'UP' received, ignoring it.")
        end
      end
    end
  end
end
