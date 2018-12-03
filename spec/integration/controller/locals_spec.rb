require "dry/view/controller"
require "dry/view/part"

RSpec.describe "locals" do

  specify "locals are decorated with parts by default" do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.template = "greeting"
      end

      expose :greeting
    end.new

    local = vc.(greeting: "Hello").locals[:greeting]

    expect(local).to be_a(Dry::View::Part)
  end

  specify "locals are not decorated if their exposure is marked as `decorate: false`" do
    vc = Class.new(Dry::View::Controller) do
      configure do |config|
        config.paths = SPEC_ROOT.join('fixtures/templates')
        config.template = "greeting"
      end

      expose :greeting, decorate: false
    end.new

    local = vc.(greeting: "Hello").locals[:greeting]

    expect(local).to eq "Hello"
  end
end
