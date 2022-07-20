# frozen_string_literal: true

require_relative 'email/email'
require_relative 'email/bounce_email'
require_relative 'config/server'
require_relative 'postmark/api'

module FakeBounce
  # Class that allows generating a bounce event
  # by sending a bounce message to the bounce server.
  class Bounce
    attr_accessor :postmark_client,
                  :bounce_server

    def self.types
      Content.bounces.keys
    end

    def initialize(bounce_server_settings, postmark_api_settings)
      init_bounce_server(bounce_server_settings)
      init_postmark_client(postmark_api_settings)
    end

    def generate(email_from, email_to, type, message_stream = nil)
      email = Email.build(email_from, email_to, type, message_stream)
      message_id = postmark_client.deliver_email(email)[:message_id]
      generate_from_id(message_id, type)
    end

    def generate_from_id(message_id, type)
      email = postmark_client.retrieve_email(message_id, 5)
      bounce_email = BounceEmail.transform_content_to_bounce(email, type)
      bounce_server.send_email(bounce_email, type)
    end

    private

    def init_postmark_client(settings)
      @postmark_client = PostmarkAPI.new(settings.fetch(:api_token), settings.fetch(:host))
    end

    def init_bounce_server(settings)
      @bounce_server = Server.new(settings.fetch(:host), settings.fetch(:bounce_address), settings.fetch(:spam_address))
    end
  end
end
