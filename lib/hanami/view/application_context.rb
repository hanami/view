# frozen_string_literal: true

require "hanami/view/errors"

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
        settings = application[:settings] if application.key?(:settings)
        helpers = application[:helpers] if application.key?(:helpers)
        routes = application[:routes_helper] if application.key?(:routes_helper)
        assets = application[:assets] if application.key?(:assets)

        define_method :initialize do |**options|
          @inflector = options[:inflector] || inflector
          @settings = options[:settings] || settings
          @helpers = options[:helpers] || helpers
          @routes = options[:routes] || routes
          @assets = options[:assets] || assets
          super(**options)
        end
      end

      module InstanceMethods
        attr_reader :inflector
        attr_reader :helpers
        attr_reader :routes
        attr_reader :settings

        def initialize(**args)
          defaults = {content: {}}

          super(**defaults.merge(args))
        end

        def content_for(key, value = nil, &block)
          content = _options[:content]
          output = nil

          if block
            content[key] = yield
          elsif value
            content[key] = value
          else
            output = content[key]
          end

          output
        end

        def current_path
          request.fullpath
        end

        def csrf_token
          request.session[Hanami::Action::CSRFProtection::CSRF_TOKEN]
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

        def assets
          @assets or
            raise Hanami::View::MissingProviderError.new("hanami-assets")
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
