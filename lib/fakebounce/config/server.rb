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

      def bounce_email_address(type)
        type.to_s.include?('spam') ? spam_address : bounce_address
      end
    end
  end
end
