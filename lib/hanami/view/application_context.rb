# frozen_string_literal: true

module Hanami
  class View
    module ApplicationContext
      def initialize(inflector: Hanami.application.inflector, **options)
        @inflector = inflector
        super
      end

      def inflector
        @inflector
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
