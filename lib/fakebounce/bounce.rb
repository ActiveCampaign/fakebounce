# frozen_string_literal: true

require_relative 'email/email'
require_relative 'email/bounce_email'
require_relative 'config/server'
require_relative 'postmark/api'
require_relative 'extensions/ruby3/mail/network/delivery_methods/smtp'

module FakeBounce
  # Class that allows generating a bounce event
  # by sending a bounce message to the bounce server.
  class Bounce
    attr_accessor :postmark_client,
                  :server

    def self.types
      Content.bounces.keys
    end

    def initialize(server, postmark_client = nil)
      @server = server
      @postmark_client = postmark_client
    end

    def generate(email_from, email_to, type, message_stream = nil)
      email = Email.build(email_from, email_to, type, message_stream)
      message_id = postmark_client.deliver_email(email)[:message_id]
      generate_from_id(message_id, type)
    end

    def generate_from_id(message_id, type)
      email = postmark_client.retrieve_email(message_id, 5)
      bounce_email = BounceEmail.tranform_to_bounce(email, type)
      send_email_to_server(bounce_email, type)
    end

    private

    def send_email_to_server(email, type)
      sending = server_init
      sending.start('HELO')
      sending.send_message(email.to_s, email[:from].to_s, server.bounce_email_address(type))
      sending.finish
    end

    def server_init
      Net::SMTP.new(server.settings[:host], server.settings[:port])
    end
  end
end
