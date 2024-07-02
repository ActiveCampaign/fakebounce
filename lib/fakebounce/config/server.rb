# frozen_string_literal: true

module FakeBounce
  class Bounce
    # Bounce server settings.
    class Server
      attr_accessor :settings,
                    :bounce_address,
                    :spam_address

      DEFAULT_SETTINGS = { host: 'localhost', port: 25, domain: 'HELO', return_response: true }.freeze

      def initialize(host, bounce_address, spam_address)
        @settings = DEFAULT_SETTINGS.merge(host: host)
        @bounce_address = bounce_address
        @spam_address = spam_address
      end

      def send_email(email, type)
        sending = open_smtp_connection
        sending.start(helo: 'HELO')
        sending.send_message(email.to_s, email[:from].to_s, bounce_email_address(type))
        sending.finish
      end

      def bounce_email_address(type)
        type.to_s.downcase.strip == 'spam' ? spam_address : bounce_address
      end

      private

      def open_smtp_connection
        Net::SMTP.new(settings.fetch(:host), settings.fetch(:port))
      end
    end
  end
end
