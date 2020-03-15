# frozen_string_literal: true

require_relative "../view"
require "hanami/view/context"

module ExampleApp
  class View
    class Context < Hanami::View::Context
      def initialize(**options)
        @options = options
        super(**options)
      end

      def request_path
        request.path
      end

      def request_fullpath
        request.fullpath
      end

      def with(**new_options)
        self.class.new(@options.merge(new_options))
      end

      def [](key)
        @options.fetch(key)
      end

      private

      def request
        self[:request]
      end
    end
  end
end
