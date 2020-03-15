# frozen_string_literal: true

require "hanami/view"
require "hanami/view/part"

RSpec.describe "View / locals" do
  specify "locals are decorated with parts by default" do
    view = Class.new(Hanami::View) do
      config.paths = SPEC_ROOT.join("fixtures/templates")
      config.template = "greeting"

      expose :greeting
    end.new

    local = view.(greeting: "Hello").locals[:greeting]

    expect(local).to be_a(Hanami::View::Part)
  end

  specify "locals are not decorated if their exposure is marked as `decorate: false`" do
    view = Class.new(Hanami::View) do
      config.paths = SPEC_ROOT.join("fixtures/templates")
      config.template = "greeting"

      expose :greeting, decorate: false
    end.new

    local = view.(greeting: "Hello").locals[:greeting]

    expect(local).to eq "Hello"
  end
end
