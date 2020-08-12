# frozen_string_literal: true

module FakeBounce
  # Email body of an email that should bounce.
  class Content
    class << self
      def retrieve_from_file(filename)
        load_from_file(filename)
      end

      private

      def root_path
        File.join(File.dirname(__FILE__), '/files')
      end

      def load_from_file(filename)
        path = "#{root_path}/#{filename}.txt"
        raise "File missing: #{filename}.txt" unless File.exist?(path)

        File.read(path)
      end
    end
  end
end
