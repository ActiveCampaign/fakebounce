# frozen_string_literal: true

if RUBY_VERSION >= '3.0.0'
  module Mail
    # Ruby 3 sets in Net::SMTP module @starttls to :auto. Old rubies set it to false.
    # This causes starttls to be always on in Mail gem when it starts smtp session, since it doesn't address setting
    # start tls to false.
    #
    # We do need tls to be sometimes off (self signed certs), so we patched Mail gem method that sends email by smtp.
    class SMTP
      private

      # new build method from https://github.com/mikel/mail/blob/57f8489ba8803188caca0e7ba78372c308765a93/lib/mail/network/delivery_methods/smtp.rb
      def build_smtp_session
        Net::SMTP.new(settings[:address], settings[:port]).tap do |smtp|
          tls = settings[:tls] || settings[:ssl]
          if !tls.nil?
            case tls
            when true
              smtp.enable_tls(ssl_context)
            when false
              smtp.disable_tls
            else
              raise ArgumentError, "Unrecognized :tls value #{settings[:tls].inspect}; expected true, false, or nil"
            end
          elsif settings.include?(:enable_starttls) && !settings[:enable_starttls].nil?
            case settings[:enable_starttls]
            when true
              smtp.enable_starttls(ssl_context)
            when false
              smtp.disable_starttls
            else
              raise ArgumentError, "Unrecognized :enable_starttls value #{settings[:enable_starttls].inspect}; expected true, false, or nil"
            end
          elsif settings.include?(:enable_starttls_auto) && !settings[:enable_starttls_auto].nil?
            case settings[:enable_starttls_auto]
            when true
              smtp.enable_starttls_auto(ssl_context)
            when false
              smtp.disable_starttls
            else
              raise ArgumentError, "Unrecognized :enable_starttls_auto value #{settings[:enable_starttls_auto].inspect}; expected true, false, or nil"
            end
          end

          smtp.open_timeout = settings[:open_timeout] if settings[:open_timeout]
          smtp.read_timeout = settings[:read_timeout] if settings[:read_timeout]
        end
      end
    end
  end
end
