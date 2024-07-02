# frozen_string_literal: true

require_relative 'email'
require_relative 'content/content'

module FakeBounce
  # Email message with bounce message body.
  class BounceEmail < Email
    class << self
      BASE_HEADER_NAMES = %w[Subject From To].freeze

      def transform_content_to_bounce(email_to_bounce, type)
        raise 'Postmark headers not present.' if postmark_header_names(email_to_bounce).empty?

        email = build(email_to_bounce[:from].to_s, email_to_bounce[:to].to_s, type)
        copy_mandatory_headers(email, email_to_bounce)
        copy_postmark_headers(email, email_to_bounce)
        append_bounce_message_body(email, type)
        email
      end

      private

      def root_path
        File.join(File.dirname(__FILE__), '/files')
      end

      def append_bounce_message_body(email, type)
        # add to the body bounce message and bounce address
        body_content = final_recipient_header(email).to_s
        body_content += Content.retrieve_from_yaml(type)
        email.body = body_content
      end

      def copy_mandatory_headers(email_new, email_to_bounce)
        append_headers(email_new, email_to_bounce, BASE_HEADER_NAMES)
      end

      def copy_postmark_headers(email_new, email_to_bounce)
        append_headers(email_new, email_to_bounce, postmark_header_names(email_to_bounce))
      end

      def append_headers(email_new, email_to_bounce, header_names)
        header_names.reject { |header_name| email_to_bounce[header_name].nil? }
                    .each { |header_name| email_new[header_name].value= email_to_bounce[header_name].value }
      end

      def final_recipient_header(email)
        header = Mail::Header.new
        header['Final-Recipient'] = "rfc822;#{email[:to]}"
        header
      end

      def postmark_header_names(email)
        email_header_names(email).select { |h| h.downcase.include?('x-pm') }
      end

      def email_header_names(email)
        email.header.fields.map(&:name)
      end
    end
  end
end
