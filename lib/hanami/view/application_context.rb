# frozen_string_literal: true

module Hanami
  class View
    class ApplicationContext < Module
      attr_reader :provider
      attr_reader :application

      def initialize(provider)
        @provider = provider
        @application = provider.respond_to?(:application) ? provider.application : Hanami.application
      end

      def included(context_class)
        define_initialize
        context_class.include(InstanceMethods)
      end

      private

      def define_initialize
        inflector = application.inflector
        routes = application[:routes_helper] if application.key?(:routes_helper)

        define_method :initialize do |**options|
          @inflector = options[:inflector] || inflector
          @routes = options[:routes] || routes
          super(**options)
        end
      end

      module InstanceMethods
        attr_reader :inflector
        attr_reader :routes

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
end
