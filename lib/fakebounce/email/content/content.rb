# frozen_string_literal: true

module FakeBounce
  # Email body of an email that should bounce.
  class Content
    class << self
      def retrieve_from_yaml(type)
        bounces = YAML.load_file("#{root_path}/bounces.yaml")
        bounces[type.to_s].map { |k, v| "#{k}: #{v}" }.join("\n")
      end

      private

      def root_path
        File.dirname(__FILE__)
      end
    end
  end
end
