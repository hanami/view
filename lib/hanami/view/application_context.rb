# frozen_string_literal: true

require_relative "context"

module Hanami
  module View
    class ApplicationContext < Context
      attr_reader :inflector

      def initialize(**options)
        @inflector = options.fetch(:inflector) { Hanami.application.inflector }
        super(**options)
      end

      def request
        _options.fetch(:request)
      end

      def session
        request.session
      end

      def flash
        response.flash
      end

      private

      # TODO: put `flash` on Request and stop passing response to view context
      def response
        _options.fetch(:response)
      end
    end
  end
end
