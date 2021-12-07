# frozen_string_literal: true

require_relative "context"
require "hanami/component"

module Hanami
  class View
    class ApplicationContext < Context
      include Hanami::Component

      attr_reader :inflector

      def initialize(**options)
        @inflector = options[:inflector] || application.inflector
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

      # TODO: create `Request#flash` so we no longer need the `response`
      def response
        _options.fetch(:response)
      end
    end
  end
end
