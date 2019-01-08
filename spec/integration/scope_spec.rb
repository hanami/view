require "dry/view/part"
require "dry/view/scope"

RSpec.describe "Scopes" do
  let(:base_vc) {
    Class.new(Dry::View::Controller) do
      config.paths = FIXTURES_PATH.join("integration/scopes")
    end
  }

  specify "Custom scope for a view controller" do
    module Test
      class ControllerScope < Dry::View::Scope
        def hello
          "Hello #{_locals[:text]}!"
        end
      end
    end

    vc = Class.new(base_vc) do
      config.template = "custom_view_controller_scope"
      config.scope = Test::ControllerScope

      expose :text
    end.new

    expect(vc.(text: "world").to_s).to eq "Hello world!"
  end

  specify "Rendering a partial via an anonymous scope" do
    vc = Class.new(base_vc) do
      config.template = "anonymous_scope"

      expose :text
    end.new

    expect(vc.(text: "Hello").to_s).to eq "Greeting: Hello"
  end

  specify "Rendering a partial implicitly via a custom named scope" do
    module Test::Scopes
      class Greeting < Dry::View::Scope
        def greeting
          _locals[:greeting].upcase + "!"
        end
      end
    end

    vc = Class.new(base_vc) do
      config.scope_namespace = Test::Scopes
      config.template = "named_scope_with_implicit_render"

      expose :text
    end.new

    expect(vc.(text: "Hello").to_s).to eq "Greeting: HELLO!"
  end

  specify "Rendering a partial implicitly via a custom named scope (provided via a class)" do
    module Test::Scopes
      class Greeting < Dry::View::Scope
        def greeting
          _locals[:greeting].upcase + "!"
        end
      end
    end

    vc = Class.new(base_vc) do
      config.scope_namespace = Test::Scopes
      config.template = "class_named_scope_with_implicit_render"

      expose :text
    end.new

    expect(vc.(text: "Hello").to_s).to eq "Greeting: HELLO!"
  end

  specify "Raising an error when an unnamed partial cannot be rendered implicitly" do
    vc = Class.new(base_vc) do
      config.template = "unnamed_named_scope_with_implicit_render"
    end.new

    expect { vc.().to_s }.to raise_error ArgumentError, "+partial_name+ must be provided for unnamed scopes"
  end

  specify "Rendering a partial explicitly via a custom named scope" do
    module Test::Scopes
      class Greeting < Dry::View::Scope
        def greeting
          _locals[:greeting].upcase + "!"
        end
      end
    end

    vc = Class.new(base_vc) do
      config.scope_namespace = Test::Scopes
      config.template = "named_scope_with_explicit_render"

      expose :text
    end.new

    expect(vc.(text: "Hello").to_s).to eq "Holler: HELLO!"
  end

  specify "Custom named scope providing defaults for missing locals" do
    module Test::Scopes
      class Greeting < Dry::View::Scope
        def greeting
          _locals.fetch(:greeting) { "Howdy" }
        end
      end
    end

    vc = Class.new(base_vc) do
      config.scope_namespace = Test::Scopes
      config.template = "named_scope_with_defaults"

      expose :text
    end.new

    expect(vc.().to_s).to eq "Greeting: Howdy"
  end

  specify "Creating a custom scope from a view part" do
    module Test::Parts
      class Message < Dry::View::Part
        def greeting
          scope(:greeting, greeting: value[:text]).render
        end
      end
    end

    module Test::Scopes
      class Greeting < Dry::View::Scope
        def greeting
          _locals[:greeting] + "!"
        end
      end
    end

    vc = Class.new(base_vc) do
      config.part_namespace = Test::Parts
      config.scope_namespace = Test::Scopes
      config.template = "scope_from_part"

      expose :message
    end.new

    expect(vc.(message: {text: "Hello from a part"}).to_s).to eq "Greeting: Hello from a part!"
  end
end
