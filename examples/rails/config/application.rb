# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DryViewExample
  class Application < Rails::Application
    config.load_defaults 5.2

    # dry-view setup
    Rails.application.config.autoload_paths << Rails.root.join("app/views")

    # Remove heinous monkey patch
    Dry::View::Part.undef_method :to_param
  end
end
