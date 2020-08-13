# frozen_string_literal: true

require_relative 'email'
require_relative 'content/content'
require 'pry'

module FakeBounce
  # Email message with bounce message body.
  class BounceEmail < Email
    class << self
      BASE_HEADER_NAMES = %w[X-PM-Message-Stream X-PM-Tag Subject From To].freeze
      MESSAGE_ID_HEADER_NAMES = %w[X-PM-Message-Id X-PM-RCPT X-PM-Message-Options].freeze

      def tranform_to_bounce(email_to_bounce, type)
        raise "#{MESSAGE_ID_HEADER_NAMES} headers not present." unless message_headers_present?(email_to_bounce)

        email = build(email_to_bounce[:from].to_s, email_to_bounce[:to].to_s, type)
        copy_mandatory_headers(email, email_to_bounce)
        copy_message_headers(email, email_to_bounce)
        append_bounce_message_body(email, type)
        email
      end

      private

      def root_path
        File.join(File.dirname(__FILE__), '/files')
      end

      def append_bounce_message_body(email, type)
        email.body = Content.retrieve_from_yaml(type)
      end

      def copy_mandatory_headers(email_new, email_to_bounce)
        append_headers(email_new, email_to_bounce, BASE_HEADER_NAMES)
      end

      def copy_message_headers(email_new, email_to_bounce)
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
