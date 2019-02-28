# frozen_string_literal: true

require "pathname"
TEMPLATE_ROOT_DIRECTORY = Pathname.new(Dir.pwd).join("spec", "support", "fixtures", "apps")

module Web
  class View < Hanami::View
    config.paths = [TEMPLATE_ROOT_DIRECTORY.join("web", "templates")]
    config.layouts_dir = [TEMPLATE_ROOT_DIRECTORY.join("web", "templates")]
    config.layout = "application"
  end

  module Views
    module Home
      class Index < Web::View
        config.template = "home/index"
      end
    end
  end
end
