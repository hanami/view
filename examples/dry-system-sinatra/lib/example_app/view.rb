# frozen_string_literal: true

# auto_register: false

require "hanami/view"
require "slim"
require "example_app/container"

module ExampleApp
  class View < Hanami::View
    config.paths = Container.root.join("web/templates")
    config.layout = "application"
  end
end
