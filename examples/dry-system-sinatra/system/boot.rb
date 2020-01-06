# frozen_string_literal: true

require_relative "example_app/container"

container = ExampleApp::Container
container.finalize!
