# frozen_string_literal: true

require_relative 'content'

module FakeBounce
  # Email message with bounce message body.
  class Email
    class << self
      BASE_HEADER_NAMES = %w[X-PM-Message-Stream Subject From To].freeze
      MESSAGE_ID_HEADER_NAMES = %w[X-PM-Message-Id X-PM-RCPT X-PM-Message-Options].freeze

      def build_with_bounce_content(email_to_bounce, type)
        raise "#{MESSAGE_ID_HEADER_NAMES} headers not present." unless message_headers_present?(email_to_bounce)

        email = build_email(type)
        append_mandatory_headers(email, email_to_bounce)
        append_message_headers(email, email_to_bounce)
        email
      end

      private

      def build_email(type)
        email = Mail.new
        email['X-PM-Tag'] = type
        email.body = Content.retrieve_from_file(type)
        email
      end

      def append_mandatory_headers(email_new, email_to_bounce)
        append_headers(email_new, email_to_bounce, BASE_HEADER_NAMES)
      end

      def append_message_headers(email_new, email_to_bounce)
        append_headers(email_new, email_to_bounce, MESSAGE_ID_HEADER_NAMES)
      end

      def append_headers(email_new, email_to_bounce, header_names)
        header_names.reject { |header_name| email_to_bounce[header_name].nil? }
                    .each { |header_name| email_new[header_name] = email_to_bounce[header_name] }
      end

      def message_headers_present?(email)
        (MESSAGE_ID_HEADER_NAMES.map(&:downcase) - email.header.map { |e| e.name.downcase }).empty?
      end
    end
  end
end
