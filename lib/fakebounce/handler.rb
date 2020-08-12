# frozen_string_literal: true

require_relative 'email'
require_relative 'server'
require 'postmark'
require 'mail'

module FakeBounce
  # Class that allows generating a bounce event, by sending a bounce message to the bounce server.
  class Handler
    attr_accessor :api_client, :bounce_server

    def initialize(api_token:, api_host:, server_host:, server_bounce_address:, server_spam_address:)
      @api_client = Postmark::ApiClient.new(api_token, host: api_host)
      @bounce_server = Server.new(server_host, server_bounce_address, server_spam_address)
    end

    def generate(email_from, email_to, type)
      message_id = deliver_email_by_api(build_simple_email(email_from, email_to, type))[:message_id]
      generate_from_id(message_id, type)
    end

    def generate_from_id(message_id, type)
      email_sent = retrieve_email_by_api(message_id, 5)
      send_email_to_bounce_server(transform_email_to_bounce(email_sent, type), type)
    end

    def send_email_to_bounce_server(email, type)
      sending = bounce_server_sending
      sending.start('HELO')
      sending.send_message(email.to_s, email[:from].to_s, bounce_server.inbox(type))
      sending.finish
    end

    private

    def bounce_server_sending
      Net::SMTP.new(bounce_server.settings[:address], bounce_server.settings[:port])
    end

    def build_simple_email(email_from, email_to, type)
      email_identifier = "Email to bounce with type: #{type}."
      Mail.new(subject: email_identifier, from: email_from, to: email_to, tag: type, body: email_identifier)
    end

    def deliver_email_by_api(email)
      api_client.deliver_message(email)
    end

    def retrieve_email_by_api(message_id, timeout_minutes)
      start = Time.now
      while Time.now - start < timeout_minutes * 60
        begin
          response = api_client.dump_message(message_id)
          return Mail.read_from_string(response[:body])
        rescue Postmark::ApiInputError
          sleep 6
        end
      end

      raise "Message with message id: #{message_id} not found."
    end

    def transform_email_to_bounce(email_sent, type)
      Email.build_with_bounce_content(email_sent, type)
    end
  end
end
