# frozen_string_literal: true

require_relative 'email/email'
require_relative 'email/bounce_email'
require_relative 'config/server'
require_relative 'postmark/api'

module FakeBounce
  # Class that allows generating a bounce event
  # by sending a bounce message to the bounce server.
  class Handler
    attr_accessor :postmark_api, :bounce_server

    def initialize(api_token:, api_host:, server_host:, server_bounce_address:, server_spam_address:)
      @postmark_api = PostmarkAPI.new(api_token, api_host)
      @bounce_server = Config::Server.new(server_host, server_bounce_address, server_spam_address)
    end

    def generate(email_from, email_to, type, message_stream = nil)
      email = Email.build(email_from, email_to, type, message_stream)
      message_id = postmark_api.deliver_email(email)[:message_id]
      generate_from_id(message_id, type)
    end

    def generate_from_id(message_id, type)
      email = postmark_api.retrieve_email(message_id, 5)
      bounce_email = BounceEmail.tranform_to_bounce(email, type)
      send_email_to_bounce_server(bounce_email, type)
    end

    private

    def send_email_to_bounce_server(email, type)
      sending = bounce_server_init
      sending.start('HELO')
      sending.send_message(email.to_s, email[:from].to_s, bounce_server.inbox(type))
      sending.finish
    end

    def bounce_server_init
      Net::SMTP.new(bounce_server.settings[:address], bounce_server.settings[:port])
    end
  end
end
