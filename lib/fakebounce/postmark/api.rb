# frozen_string_literal: true

require 'postmark'
require 'mail'

module FakeBounce
  # Postmark API client requests wrapper
  class PostmarkAPI
    attr_accessor :client

    def initialize(api_token, host)
      @client = Postmark::ApiClient.new(api_token, host: host)
    end

    def retrieve_email(message_id, timeout_minutes)
      start = Time.now
      while Time.now - start < timeout_minutes * 60
        begin
          response = client.dump_message(message_id)
          return Mail.read_from_string(response[:body])
        rescue Postmark::ApiInputError
          sleep 6
        end
      end

      raise "Message with message id: #{message_id} not found."
    end
  end
end
