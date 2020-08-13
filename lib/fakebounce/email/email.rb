# frozen_string_literal: true

require 'mail'

module FakeBounce
  # Email message with bounce message body.
  class Email
    class << self
      def build(email_from, email_to, type, message_stream = nil)
        email_identifier = 'Email to bounce.'
        mail = Mail.new(subject: email_identifier, from: email_from, to: email_to, body: email_identifier)
        mail['X-PM-Tag'] = type
        mail['X-PM-Message-Stream'] = message_stream unless message_stream.nil?
        mail
      end
    end
  end
end
