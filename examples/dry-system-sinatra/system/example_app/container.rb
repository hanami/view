# frozen_string_literal: true

require "dry/web/container"
require "dry/system/components"

module ExampleApp
  class Container < Dry::Web::Container
    configure do
      config.name = :example_app
      config.log_levels = %i[test development production].map { |e| [e, Logger::DEBUG] }.to_h
      config.default_namespace = "example_app"
      config.auto_register = %w[lib/example_app]
    end

    load_paths! "lib"
  end
end
