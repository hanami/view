# frozen_string_literal: true

require "hanami"
require "hanami/view/context"

RSpec.describe "Application context / Helpers", :application_integration do
  it "accesses application helpers" do
    with_tmp_directory(Dir.mktmpdir) do
      write "config/application.rb", <<~RUBY
        require "hanami"

        module TestApp
          class Application < Hanami::Application
            register_slice :main
          end
        end
      RUBY

      write "lib/test_app/view/base.rb", <<~RUBY
        module TestApp
          module View
            class Base < Hanami::View
            end
          end
        end
      RUBY

      write "lib/test_app/view/context.rb", <<~RUBY
        module TestApp
          module View
            class Context < Hanami::View::Context
            end
          end
        end
      RUBY

      require "hanami/prepare"

      context = TestApp::View::Context.new
      expect(context.helpers).to be_kind_of(Dry::Core::BasicObject)
    end
  end

  it "can inject helpers" do
    module TestApp
      class Application < Hanami::Application
      end
    end
    Hanami.prepare
    module TestApp
      module View
        class Context < Hanami::View::Context
        end
      end
    end
    helpers = double(:helpers)

    context = TestApp::View::Context.new(helpers: helpers)

    expect(context.helpers).to be(helpers)
  end
end
