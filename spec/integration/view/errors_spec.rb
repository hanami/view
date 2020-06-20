# frozen_string_literal: true

require "hanami/view"
require "hanami/view/context"

RSpec.describe "View / errors" do
  specify "Raising an error when paths are not configured" do
    view = Class.new(Hanami::View) {
      config.template = "hello"
    }.new

    expect { view.() }.to raise_error(Hanami::View::UndefinedConfigError, "no +paths+ configured")
  end

  specify "Raising an error when template is not configured" do
    view = Class.new(Hanami::View) {
      config.paths = FIXTURES_PATH.join("integration/errors")
    }.new

    expect { view.() }.to raise_error(Hanami::View::UndefinedConfigError, "no +template+ configured")
  end
end
