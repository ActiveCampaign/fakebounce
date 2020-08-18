# frozen_string_literal: true

module FakeBounce
  # Email body to use in an email to make it bounce when sent to bounce server.
  class Content
    class << self
      def retrieve_from_yaml(type)
        bounces[type.to_s].map { |k, v| "#{k}: #{v}" }.join("\n")
      end

      def bounces
        YAML.load_file("#{root_path}/bounces.yaml")
      end

      private

      def root_path
        File.dirname(__FILE__)
      end
    end
  end
end
